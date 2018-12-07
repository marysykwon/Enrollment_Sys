set echo on
set serveroutput on

/* ---------------
   Create table structure
   --------------- */

drop table enrollments;
drop table waitlist;
drop table enrollment_audit;
drop table prereq;
drop table schclasses;
drop table courses;
drop table students;
drop table majors;

-----
-----


create table MAJORS
	(major varchar2(3) Primary key,
	mdesc varchar2(30));
insert into majors values ('ACC','Accounting');
insert into majors values ('FIN','Finance');
insert into majors values ('IS','Information Systems');
insert into majors values ('MKT','Marketing');

create table STUDENTS 
	(snum varchar2(3) primary key,
	sname varchar2(10),
	standing number(1),
	major varchar2(3) constraint fk_students_major references majors(major),
	gpa number(2,1),
	major_gpa number(2,1));

insert into students values ('101','Andy',3,'IS',2.8,3.2);
insert into students values ('102','Betty',2,null,3.2,null);
insert into students values ('103','Cindy',1,'IS',2.5,3.5);
insert into students values ('104','David',2,'FIN',3.3,3.0);
insert into students values ('105','Ellen',1,null,2.8,null);
insert into students values ('106','Frank',3,'MKT',3.1,2.9);
insert into students values ('107','Mary',4,'IS',3.6,null);
insert into students values ('108','John',3,'IS',1.5,3.7);
insert into students values ('109','Sam',2,'ACC',3.1,2.4);
insert into students values ('110','Clay',1,null,1.9,null);
insert into students values ('111','Nate',3,'MKT',3.4,2.5);

create table COURSES
	(dept varchar2(3) constraint fk_courses_dept references majors(major),
	cnum varchar2(3),
	ctitle varchar2(30),
	crhr number(3),
	standing number(1),
	primary key (dept,cnum));

insert into courses values ('IS','300','Intro to MIS',3,2);
insert into courses values ('IS','301','Business Communicatons',3,2);
insert into courses values ('IS','310','Statistics',3,2);
insert into courses values ('IS','340','Programming',3,3);
insert into courses values ('IS','380','Database',3,3);
insert into courses values ('IS','385','Systems',3,3);
insert into courses values ('IS','480','Adv Database',3,4);
insert into courses values ('IS','233','IS Basics',3,1);

create table SCHCLASSES (
	callnum number(5) primary key,
	year number(4),
	semester varchar2(3),
	dept varchar2(3),
	cnum varchar2(3),
	section number(2),
	capacity number(3));

alter table schclasses 
	add constraint fk_schclasses_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);

insert into schclasses values (10110,2014,'Fa','IS','300',1,4);
insert into schclasses values (10115,2014,'Fa','IS','300',2,3);
insert into schclasses values (10120,2014,'Fa','IS','300',3,3);
insert into schclasses values (10125,2014,'Fa','IS','301',1,2);
insert into schclasses values (10130,2014,'Fa','IS','301',2,3);
insert into schclasses values (10135,2014,'Fa','IS','310',1,2);
insert into schclasses values (10140,2014,'Fa','IS','310',2,3);
insert into schclasses values (10145,2014,'Fa','IS','340',1,2);
insert into schclasses values (10150,2014,'Fa','IS','380',1,3);
insert into schclasses values (10155,2014,'Fa','IS','385',1,3);
insert into schclasses values (10160,2014,'Fa','IS','480',1,2);
insert into schclasses values (10165,2014,'Fa','IS','233',1,2);

create table PREREQ
	(dept varchar2(3),
	cnum varchar2(3),
	pdept varchar2(3),
	pcnum varchar2(3),
	primary key (dept, cnum, pdept, pcnum));
alter table Prereq 
	add constraint fk_prereq_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);
alter table Prereq 
	add constraint fk_prereq_pdept_pcnum foreign key 
	(pdept, pcnum) references courses (dept,cnum);

insert into prereq values ('IS','380','IS','300');
insert into prereq values ('IS','380','IS','301');
insert into prereq values ('IS','380','IS','310');
insert into prereq values ('IS','385','IS','310');
insert into prereq values ('IS','340','IS','300');
insert into prereq values ('IS','480','IS','380');

create table ENROLLMENTS (
	snum varchar2(3) constraint fk_enrollments_snum references students(snum),
	callnum number(5) constraint fk_enrollments_callnum references schclasses(callnum),
	grade varchar2(2),
	primary key (snum, callnum));

insert into enrollments values (101,10110,'A');
insert into enrollments values (102,10110,'B');
insert into enrollments values (103,10120,'A');
insert into enrollments values (101,10125,null);
insert into enrollments values (109,10125,null);
insert into enrollments values (102,10130,null);


create table waitlist (
	snum varchar2(3) constraint fk_waitlist_snum references students(snum),
	callnum number(5) constraint fk_waitlist_callnum references schclasses(callnum),
	wltime date);

create table enrollment_audit (
	snum varchar2(3) constraint fk_enrollment_audit_snum references students(snum),
	callnum number(5) constraint fk_enrollment_audit_callnum references schclasses(callnum),
	droptime date,
	status varchar2(2));

create or replace trigger afterdelete
	after delete on enrollments
	for each row
begin
	insert into enrollment_audit values (:old.snum, :old.callnum, sysdate, 'W');
end;
/


commit;

create or replace package enroll is

function validate_student (
	p_snum students.snum%type)
	return varchar2;

procedure validate_callnum (
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2);

procedure repeat_enroll (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2);

procedure dub_enroll (
	p_snum students.snum%type,
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2);

procedure validate_crhr (
	p_snum students.snum%type,
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2);

procedure standing_req (
	p_snum students.snum%type,
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2);

procedure disq (
	p_snum students.snum%type,
	p_error_text out varchar2);

procedure checkcap (
	p_callnum enrollments.callnum%type,
	p_error_text out varchar2);

procedure wl (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2);

procedure addme (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_msg out varchar2);

procedure not_enroll (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2);

procedure already_grade (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2);

procedure dropme (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type);

end enroll;
/


create or replace package body enroll is

function validate_student (
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

procedure Validate_callnum (
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

procedure repeat_enroll (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2) as
	
	v_count number(3);

	begin
		select count(*) into v_count
		from enrollments
		where snum=p_snum and callnum=p_callnum;

		if v_count = 0 then
			p_error_text := null;
		else
			p_error_text := 'Student Number '||p_snum||' already enrolled in call number '||p_callnum||'. ';
		end if;
	end;

procedure dub_enroll (
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

procedure validate_crhr (
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

procedure standing_req (
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

procedure disq (
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

procedure checkcap (
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

procedure wl (
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

procedure addme (
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

procedure not_enroll (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2) as
	
	v_count number(3);

	begin
		select count(*) into v_count
		from enrollments
		where snum = p_snum and callnum = p_callnum;

		if v_count = 0 then
			p_error_text := 'Error: You cannot drop a class you are not enrolled in.';
		else
			p_error_text := null;
		end if;

	end;

procedure already_grade (
	p_snum students.snum%type,
	p_callnum schclasses.callnum%type,
	p_error_text out varchar2) as
	
	v_count number(3);

	begin
		select count(grade) into v_count
		from enrollments
		where snum = p_snum and callnum = p_callnum;

		if v_count > 0 then
			p_error_text := 'Error: Grade is already assigned. You cannot drop from this course. ';

		elsif v_count = 0 then
			p_error_text := null;
		end if;

	end;

procedure dropme (
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


end enroll;
/
