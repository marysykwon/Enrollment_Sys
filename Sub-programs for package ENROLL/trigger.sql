set serveroutput on
set echo on

create or replace trigger afterdelete
	after delete on enrollments
	for each row
begin
	insert into enrollment_audit values (:old.snum, :old.callnum, sysdate, 'W');
end;
/
