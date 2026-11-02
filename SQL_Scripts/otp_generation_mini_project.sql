create table otp_creation_details
(
  phone_number number,
  OTP_number number,
  OTP_Created_date Timestamp,
  OTP_expired_date Timestamp,
  status varchar2(20) default 'Active',
  attempt_count number
);
/

create or replace procedure otp_generation
(
  p_phone_number in number,
  p_otp out number
)
is
begin
select trunc(dbms_random.value(100000,999999)) into p_otp from dual;
insert into otp_creation_details(phone_number,OTP_Number,OTP_Created_date,OTP_expired_date,status,attempt_count) values(p_phone_number,p_otp,SYSDATE,SYSDATE+(1.5/1440),'Active',0);
end;
/
create or replace procedure otp_verification
(v_otp in number,v_attempt_count out number,v_phone_number in number
)
is
v_db_otp number;
begin
 select OTP_NUMBER,attempt_count into v_db_otp,v_attempt_count from otp_creation_details
 where v_phone_number=phone_number and status='Active';
 if v_db_otp=v_otp then
 dbms_output.put_line('Otp verified successfully');
 --insert into otp_creation_details(phone_number,OTP_number,OTP_Created_date,OTP_expired_date,status,attempt_count) values(p_phone_number,p_otp,SYSDATE,SYSDATE+(1.5/1440),'used',v_attempt_count);
 update otp_creation_details set status='expired' where phone_number=v_phone_number;
 else
 dbms_output.put_line('Enter correct otp');
 v_attempt_count:=v_attempt_count+1;
 update otp_creation_details set attempt_count=v_attempt_count where phone_number=v_phone_number and status='Active';
   if v_attempt_count>3 then
     dbms_output.put_line('The OTP has expired and Enter new OTP');
     update otp_creation_details set status='Expired' where phone_number=v_phone_number and status='Active';
   end if;
 end if;
end;
/
set SERVEROUTPUT on;
declare
p_otp number;
begin
  otp_generation(9848427391,p_otp);
  dbms_output.put_line('Generated OTP is:'||p_otp);  
end;
/
set SERVEROUTPUT on;
declare
v_attempt_count number;
begin
  --select ATTEMPT_COUNT into v_attempt_count from otp_creation_details where status='Active';
  otp_verification(123636,v_attempt_count,9848427391);
  dbms_output.put_line('attempts'||v_attempt_count);
  
end;
/
select * from otp_creation_details;
delete from otp_creation_details;
commit;