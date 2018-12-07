set serveroutput on
set echo on

create or replace procedure repeat_enroll (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2) as
	
	v_count number(3);

begin
	select count(*) into v_count
	from enrollments
	where snum=p_snum and callnum=p_callnum;

	if v_count = 0 then
		p_error_text := null;
	else
		p_error_text := 'Student Number '||p_snum||' already enrolled in call number '||p_callnum||'. ';
	end if;
end;
/
