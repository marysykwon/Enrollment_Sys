set serveroutput on
set echo on

create or replace procedure addme (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_msg out varchar2) as

	v_error_text varchar2(1000);
	v_error_msg varchar2(1000);

begin
	v_error_text := validate_student(p_snum);
	v_error_msg := v_error_text;
	p_error_msg := v_error_msg;

	Validate_callnum(p_callnum, v_error_text);
	v_error_msg := v_error_msg || v_error_text;
	p_error_msg := v_error_msg;

	if v_error_msg is null then

		disq(p_snum, v_error_text);
		v_error_msg := v_error_text;
		p_error_msg := v_error_msg;

		repeat_enroll(p_snum, p_callnum, v_error_text);
		v_error_msg := v_error_msg || v_error_text;
		p_error_msg := v_error_msg;
		
		dub_enroll (p_snum, p_callnum, v_error_text);
		v_error_msg := v_error_msg || v_error_text;
		p_error_msg := v_error_msg;
		
		validate_crhr(p_snum, p_callnum, v_error_text);
		v_error_msg := v_error_msg || v_error_text;
		p_error_msg := v_error_msg;

		standing_req(p_snum, p_callnum, v_error_text);
		v_error_msg := v_error_msg || v_error_text;
		p_error_msg := v_error_msg;

		checkcap(p_callnum, v_error_text);
		v_error_msg := v_error_msg || v_error_text;
		p_error_msg := v_error_msg;

		if v_error_msg = 'Sorry, course capacity is at max. ' then
			dbms_output.put_line (v_error_msg);
			wl(p_snum, p_callnum, v_error_text);
			dbms_output.put_line (v_error_text);
		
		elsif v_error_msg is null then
			insert into enrollments values (p_snum, p_callnum, null);
			dbms_output.put_line ('Congratulations, '||p_snum||' successfully enrolled in '||p_callnum||'.');
		else
			dbms_output.put_line (v_error_msg);
		end if;
	else
		dbms_output.put_line (v_error_msg);
	end if;

end;
/

