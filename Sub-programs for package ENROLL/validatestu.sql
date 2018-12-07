set serveroutput on
set echo on



create or replace function validate_student (
	p_snum students.snum%type)

	return varchar2 is

	v_count number(3);
	v_error_text varchar(100);

begin
	select count(*) into v_count
	from students
	where snum=p_snum;

	if v_count = 0 then
		v_error_text := 'Student Number'||p_snum||' Invalid. ';
	else
		v_error_text := null;
	end if;
	
	return v_error_text;

end;
/


