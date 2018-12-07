set serveroutput on
set echo on

create or replace procedure wl (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2) as

	v_count number;

begin
	select count(*) into v_count
	from waitlist
	where snum = p_snum and callnum = p_callnum;

	if v_count = 0 then
		insert into waitlist values (p_snum,p_callnum, sysdate);
		p_error_text := 'Student number '||p_snum||' is now on the waiting list for class number '||p_callnum||'.';

	else
		p_error_text := 'You are already on the waiting list for class number '||p_callnum||'.';
	end if;

end;
/


