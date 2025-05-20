alter session set container=ORCLPDB1;
@/opt/oracle/product/19c/dbhome_1/demo/schema/human_resources/hr_main.sql hr users temp /opt/oracle/product/19c/dbhome_1/demo/schema/log/hr_install.log 
alter user hr identified by hr account unlock;
conn hr/hr@ORCLPDB1
select * from employees;