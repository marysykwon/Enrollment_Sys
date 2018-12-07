set serveroutput on
set echo on

create or replace procedure standing_req (
	p_snum students.snum%type,
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2) as

	v_c_standing number;
	v_s_standing number;

begin
	select standing into v_s_standing
	from students
	where snum = p_snum;

	select standing into v_c_standing 
	from schclasses s, courses c
	where callnum = p_callnum and s.dept = c.dept and s.cnum = c.cnum;

	if v_s_standing >= v_c_standing then
		p_error_text := null;
	else 
		p_error_text := 'You do not meet the course standing requirements.';
	end if;
end;
/


