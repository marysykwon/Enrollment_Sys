<?php 
// This is for CSULB 10g
// $conn = oci_connect('sophie', 'sophie', '//134.139.81.33/cba10g');

// This is for CBA 11g
// Copy from tnsnames.ora

$db="(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = CBA-DBSrv01.campus.ad.csulb.edu)(PORT = 1521)))
    (CONNECT_DATA =
      (SID = orcl)
      (SERVER = DEDICATED)))";

$conn = oci_connect('zkw6160', 'password', $db);

// accept screen input
$vSnum_php = $_REQUEST['vSNum_form'];
$vCallNum_php = $_REQUEST['vCallNum_form'];

// create SQL statement to call MyAddMe (IN,IN,OUT)
$sql = 'BEGIN MyAddME(:vSnum, :vCallnum, :vMsg); END; ';
$stmt = oci_parse($conn, $sql);

// bind screen input to parameters 
oci_bind_by_name ($stmt, ':vSnum', $vSnum_php, 32);
oci_bind_by_name ($stmt, ':vCallNum', $vCallNum_php, 32);
oci_bind_by_name ($stmt, ':vMsg', $vMsg_php, 1000);

// Execute the SQL statement
oci_execute ($stmt);

// Print the out parameter
print "$vMsg_php\n";
