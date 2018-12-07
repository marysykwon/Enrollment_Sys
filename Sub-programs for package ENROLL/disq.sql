set serveroutput on
set echo on

create or replace procedure disq (
	p_snum students.snum%type,
	p_error_text out varchar2) as

	v_gpa number(2,1);
	v_standing number;

begin
	select standing into v_standing
	from students
	where snum = p_snum;

	if v_standing > 1 then

		select gpa into v_gpa 
		from students
		where snum=p_snum;

		if v_gpa < 2 then
			p_error_text := 'You are a disqualified student. You cannot enroll in any courses.';
		else
			p_error_text := null;
		end if;
	else
		p_error_text := null;
	end if;
end;
/
