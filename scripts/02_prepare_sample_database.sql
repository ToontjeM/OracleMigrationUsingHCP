alter session set container=ORCLPDB1;
@/opt/oracle/product/21c/dbhome_1/demo/db-sample-schemas-21.1/mksample.sql oracle oracle hrpw oepw pmpw ixpw shpw bipw users temp /opt/oracle/product/21c/dbhome_1/demo/schema/log/mksample.log 

GRANT SELECT ON V$VERSION TO hr;
GRANT SELECT ON V$INSTANCE TO hr;
GRANT SELECT ON V$LICENSE TO hr;
GRANT SELECT ON sys.all_tables TO hr;
GRANT SELECT ON sys.all_tab_privs TO hr;
GRANT SELECT_CATALOG_ROLE TO hr;
GRANT SELECT ANY DICTIONARY TO hr;

alter user hr identified by hr account unlock;

conn / as sysdba
alter system set db_recovery_file_dest_size = 10G scope=spfile;
alter system set db_recovery_file_dest = '/opt/oracle/oradata/ORCLCDB/fast_recovery_area' scope=spfile;
startup mount
alter database archivelog;
alter database open;
archive log list;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
BEGIN
  FOR t IN (
    SELECT owner, table_name
    FROM all_tables
    WHERE owner IN ('HR' ) -- Replace with your schemas, use UPPERCASE
      AND temporary = 'N'
  )
  LOOP
    BEGIN
      EXECUTE IMMEDIATE
        'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS';
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Failed to alter table ' || t.owner || '.' || t.table_name || ': ' || SQLERRM);
    END;
  END LOOP;
END;
/

CREATE TABLESPACE HR DATAFILE '/opt/oracle/oradata/ORCLCDB/logminer_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
CREATE TABLESPACE HR DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCPDB1/logminer_tbs_1.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

CREATE USER migrationuser IDENTIFIED BY migration
    DEFAULT TABLESPACE migration
    QUOTA UNLIMITED ON migrationuser
    CONTAINER=ALL;
GRANT CREATE SESSION TO migrationuser CONTAINER=ALL;
GRANT SET CONTAINER TO migrationuser CONTAINER=ALL;
GRANT SELECT ON V_$DATABASE to migrationuser CONTAINER=ALL;
GRANT FLASHBACK ANY TABLE TO migrationuser CONTAINER=ALL;
GRANT SELECT ANY TABLE TO migrationuser CONTAINER=ALL;
GRANT SELECT_CATALOG_ROLE TO migrationuser CONTAINER=ALL;
GRANT EXECUTE_CATALOG_ROLE TO migrationuser CONTAINER=ALL;
GRANT SELECT ANY TRANSACTION TO migrationuser CONTAINER=ALL;
GRANT SELECT ANY DICTIONARY TO migrationuser CONTAINER=ALL;
GRANT LOGMINING TO migrationuser CONTAINER=ALL;
GRANT CREATE TABLE TO migrationuser CONTAINER=ALL;
GRANT LOCK ANY TABLE TO migrationuser CONTAINER=ALL;
GRANT CREATE SEQUENCE TO migrationuser CONTAINER=ALL;
GRANT EXECUTE ON DBMS_LOGMNR TO migrationuser CONTAINER=ALL;
GRANT EXECUTE ON DBMS_LOGMNR_D TO migrationuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_LOGS TO migrationuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO migrationuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGFILE TO migrationuser CONTAINER=ALL;
GRANT SELECT ON V_$ARCHIVED_LOG TO migrationuser CONTAINER=ALL;
GRANT SELECT ON V_$ARCHIVE_DEST_STATUS TO migrationuser CONTAINER=ALL;
GRANT SELECT ON V_$TRANSACTION TO migrationuser CONTAINER=ALL;
BEGIN
  FOR t IN (
    SELECT owner, table_name
    FROM all_tables
    WHERE owner IN ('HR' ) -- Replace with your schemas, use UPPERCASE
      AND temporary = 'N'
  )
  LOOP
    BEGIN
      EXECUTE IMMEDIATE
        'GRANT SELECT ON "' || t.owner || '"."' || t.table_name || '" TO migrationuser';
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Failed to alter table ' || t.owner || '.' || t.table_name || ': ' || SQLERRM);
    END;
  END LOOP;
END;
/



conn hr/hr@ORCLPDB1
select * from employees;