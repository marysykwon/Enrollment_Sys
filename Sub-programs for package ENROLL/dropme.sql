set serveroutput on
set echo on

create or replace procedure dropme (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type) as

	v_error_text varchar2(1000);
	v_error_msg varchar2(1000);

	cursor wlrecord is
		select snum, callnum, wltime 
		from waitlist where callnum = p_callnum 
		order by wltime;

begin

	v_error_text := validate_student(p_snum);
	v_error_msg := v_error_text;

	Validate_callnum(p_callnum, v_error_text);
	v_error_msg := v_error_msg || v_error_text;

	if v_error_msg is null then
		
		not_enroll(p_snum, p_callnum, v_error_text);
		v_error_msg := v_error_text;

		already_grade(p_snum, p_callnum, v_error_text);
		v_error_msg := v_error_msg || v_error_text;

		if v_error_msg is null then
			delete from enrollments 
			where snum = p_snum and callnum = p_callnum;
			
			dbms_output.put_line('You have successfully dropped from course number '||p_callnum);

			for eachstudent in wlrecord loop
				exit when wlrecord%notfound;
				addme(eachstudent.snum, eachstudent.callnum, v_error_text);
				if v_error_text is null then
					delete from waitlist 
					where snum = eachstudent.snum and callnum = eachstudent.callnum;
					exit;
				end if;
			end loop;
		else
			dbms_output.put_line (v_error_msg);
		end if;
	else
		dbms_output.put_line (v_error_msg);
	end if;
end;
/


