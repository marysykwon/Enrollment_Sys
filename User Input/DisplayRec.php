<?php 

// DisplayRec.php: Display ONE student record from Oracle with user input

// Connect to CBA Oracle 11g
$db="(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = CBA-DBSrv01.campus.ad.csulb.edu)(PORT = 1521)))
    (CONNECT_DATA =
      (SID = orcl)
      (SERVER = DEDICATED)))";

$conn = oci_connect('zkw6160', 'password', $db);

$vSNum_php = $_REQUEST['vSNum_form'];
do_query($conn, 'SELECT * FROM STUDENTS where snum=' . $vSNum_php);

// Execute query and display results 
function do_query($conn, $query)
{
  $stid = oci_parse($conn, $query);
  $r = oci_execute($stid, OCI_DEFAULT);

  print '<table border="1">';
  while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
    print '<tr>';
    foreach ($row as $item) {
      print '<td>'.
            ($item ? htmlentities($item) : '&nbsp;').'</td>';
    }
    print '</tr>';
  }
  print '</table>';
}

?>
