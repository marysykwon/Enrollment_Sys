set serveroutput on
set echo on

create or replace procedure not_enroll (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2) as
	
	v_count number(3);

begin
	select count(*) into v_count
	from enrollments
	where snum = p_snum and callnum = p_callnum;

	if v_count = 0 then
		p_error_text := 'Error: You cannot drop a class you are not enrolled in.';
	else
		p_error_text := null;
	end if;

end;
/
