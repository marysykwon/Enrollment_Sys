set serveroutput on
set echo on

create or replace procedure already_grade (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2) as
	
	v_count number(3);

begin
	select count(grade) into v_count
	from enrollments
	where snum = p_snum and callnum = p_callnum;

	if v_count > 0 then
		p_error_text := 'Error: Grade is already assigned. You cannot drop from this course. ';

	elsif v_count = 0 then
		p_error_text := null;
	end if;

end;
/
