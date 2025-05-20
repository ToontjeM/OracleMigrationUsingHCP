#!/bin/bash

set -e -E -u -o pipefail

trap 'errcode=$?; trap ERR; echo 1>&2 "Error $BASH_SOURCE:$LINENO $BASH_COMMAND: exit code $?"; exit $errcode;' ERR

function usage() {
    echo 1>&2 "Usage: $0 [OPTIONS]"
    echo 1>&2
    echo 1>&2 "Install the static pull secret to the current k8s or rhos cluster"
    echo 1>&2
    echo 1>&2 "Options:"
    echo 1>&2 "  -h    Show this help message"
    echo 1>&2 "  -u    Username to the container registry"
    echo 1>&2 "  -s    Server of the container registry"
    echo 1>&2 "  -t    Cluster type, k8s or rhos"
    echo 1>&2
    echo 1>&2 "Requirements:"
    echo 1>&2 "  - kubectl CLI installed and configured"
    echo 1>&2 "  - oc CLI installed and configured (when using rhos)"
}

reg_secret_name="edb-cred"
registry="docker.enterprisedb.com"
username="staging_pgai-platform"
cluster_type="k8s"
password=""

function install_cred_k8s() {
    echo "Creating secret ${reg_secret_name}"
    # we install secret in upm-replicator namespace to make sure
    # that the secret is available to all the upm components
    kubectl create namespace upm-replicator --dry-run=client -o yaml | kubectl apply -f -
    kubectl create secret docker-registry ${reg_secret_name} \
        --dry-run=client \
        -n upm-replicator \
        --docker-server="${registry}" \
        --docker-username="${username}" \
        --docker-password="${password}" \
        -o yaml | kubectl apply -f -

    # we also need to create a namespace for edbpgai-bootstrap
    # and have secret created in that namespace in case the user
    # wants to use the bootstrap job to install the EDBPGAI
    kubectl create namespace edbpgai-bootstrap --dry-run=client -o yaml | kubectl apply -f -
    kubectl create secret docker-registry ${reg_secret_name} \
        --dry-run=client \
        -n edbpgai-bootstrap \
        --docker-server="${registry}" \
        --docker-username="${username}" \
        --docker-password="${password}" \
        -o yaml | kubectl apply -f -

    # sync secret regcred from default namspace to all namespaeces
    # require pulls from upm registries
    local replicate_to
    replicate_to="*"
    kubectl annotate secret -n upm-replicator ${reg_secret_name} \
        replicator.v1.mittwald.de/replicate-to="${replicate_to}" --overwrite
    echo "Installation completed"
}

function create_regcred_secret() {
    echo "Creating secret regcred"
    kubectl create secret docker-registry ${reg_secret_name} \
        --dry-run=client \
        --docker-server="${registry}" \
        --docker-username="${username}" \
        --docker-password="${password}" \
        -o yaml | kubectl apply -f -

    # sync secret regcred from default namspace to various namespaces that
    # require pulls from upm registries
    local replicate_to
    replicate_to="istio-system"
    kubectl annotate secret ${reg_secret_name} \
        replicator.v1.mittwald.de/replicate-to="${replicate_to}" --overwrite
}

function install_cred_rhos() {
    oc get secret/pull-secret -n openshift-config \
        --template='{{index .data ".dockerconfigjson" | base64decode}}' \
        > "$tmpdir/pull-secret"

    oc registry login \
        --registry="${registry}" \
        --auth-basic="${username}:${password}" \
        --to="$tmpdir/pull-secret"

    oc set data secret/pull-secret -n openshift-config \
        --from-file=.dockerconfigjson="$tmpdir/pull-secret"

    create_regcred_secret
    echo "The global pull secret for ${registry} has been updated. This update can take some time to take effect."
}

while getopts "u:p:s:t:h" opt; do
    case $opt in
        u)
            username="$OPTARG"
            ;;
        p)
            password="$OPTARG"
            ;;
        s)
            registry="$OPTARG"
            ;;
        t)
            cluster_type="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo 1>&2 "Invalid option: -${opt}" >&2
            echo 1>&2
            usage
            exit 1
            ;;
    esac
done

if [ -z "$username" ]; then
    echo 1>&2 "Error: username is required" >&2
    echo 1>&2
    usage
    exit 1
fi

if [ -z "$registry" ]; then
    echo 1>&2 "Error: server is required" >&2
    echo 1>&2
    usage
    exit 1
fi

echo "Enter the password for ${username}@${registry}"
read -s password

if [ -z "$password" ]; then
    echo 1>&2 "Error: password is required" >&2
    echo 1>&2
    usage
    exit 1
fi

function install() {
    tmpdir=$(mktemp -d /tmp/pull-secret-XXXXXX) # Linux GNU and MacOS compatible
    chmod 0700 "${tmpdir}"
    trap 'rm -r $tmpdir' EXIT

    case "${cluster_type}" in
        k8s)
            install_cred_k8s
            ;;
        rhos)
            install_cred_rhos
            ;;
        *)
            echo 1>&2 "ERROR: -t is required and must be \"k8s\" or \"rhos\" not \"${cluster_type}\""
            usage
            exit 1
            ;;
    esac

    rm -r "${tmpdir}"
    trap EXIT
}

install

trap ERR
