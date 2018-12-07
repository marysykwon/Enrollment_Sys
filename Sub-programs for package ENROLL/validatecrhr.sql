set serveroutput on
set echo on

create or replace procedure validate_crhr (
	p_snum students.snum%type,
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2) as

	v_crhr_toadd number;
	v_crhr_enrolled number;
begin

	select crhr into v_crhr_toadd
	from schclasses, courses
	where p_callnum = callnum and schclasses.dept = courses.dept and schclasses.cnum=courses.cnum;

	select sum(nvl(crhr, 0)) into v_crhr_enrolled
	from enrollments e, schclasses s, courses c
	where snum=p_snum and e.callnum=s.callnum and s.dept=c.dept and s.cnum=c.cnum;
	if sql%notfound then
		p_error_text := null;
	end if;

	if v_crhr_toadd + v_crhr_enrolled <= 15 then
		p_error_text := null;
	end if; 

	if v_crhr_toadd + v_crhr_enrolled > 15 then
		p_error_text := 'You cannot enroll in more than 15 units. ';
	end if;

end;
/
