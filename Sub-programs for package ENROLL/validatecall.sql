set serveroutput on
set echo on

create or replace procedure Validate_callnum (
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2) as
	
	v_count number(3);

begin
	select count(*) into v_count
	from schclasses
	where callnum=p_callnum;

	if v_count = 0 then
		p_error_text := 'Call Number '||p_callnum||' Invalid. ';
	else
		p_error_text := null;
	end if;
		
end;
/


