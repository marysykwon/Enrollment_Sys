set serveroutput on
set echo on

create or replace procedure dub_enroll (
	p_snum students.snum%type,
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2) as

	v_count number;
	v_deptwant varchar2(100);
	v_cnumwant varchar2(100);
	
begin
	select dept into v_deptwant
	from schclasses
	where callnum = p_callnum;

	select cnum into v_cnumwant
	from schclasses
	where callnum = p_callnum;

	select count(*) into v_count
	from schclasses, enrollments
	where schclasses.callnum = enrollments.callnum and snum = p_snum and dept = v_deptwant and cnum = v_cnumwant and enrollments.callnum != p_callnum;

	if v_count = 0 then
		p_error_text := null;
	else 
		p_error_text := 'You are already enrolled in another section of the same course.';
	end if;
end;
/
