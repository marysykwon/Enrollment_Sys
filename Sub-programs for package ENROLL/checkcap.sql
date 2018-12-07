set serveroutput on
set echo on


create or replace procedure checkcap (
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2) as

	v_count number;
	v_capacity number;
begin
	select count(callnum) into v_count
	from enrollments
	where callnum = p_callnum;

	select capacity into v_capacity
	from schclasses
	where callnum = p_callnum;

	if v_count < v_capacity then
		p_error_text := null;
	else
		p_error_text := 'Sorry, course capacity is at max. ';
	end if;
end;
/
