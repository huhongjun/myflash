<?php
/* 	���ݿ����Ӳ���	*/
$dbms='mysql';    	//���ݿ����� Oracle ��ODI
$host='localhost';		//���ݿ�������
$dbName='amfphp';   	//ʹ�õ����ݿ�
$user='root';     		//���ݿ������û���
$pass='root';         	//��Ӧ������
$dsn="$dbms:host=$host;dbname=$dbName";

/*	���ò�������	*/
$circleoid ="";
$circlecx = 0;
$circlecy = 0;

$circlexml = "";
$svgxml ="";

try{
	/*	��ʼ��һ��PDO���󣬾��Ǵ��������ݿ����Ӷ���	*/
	$dbh=new PDO($dsn,$user,$pass);
	//echo "���ӳɹ�<br/>";	//������;

	/*	�Ӵ��������ò�ѯ����	*/
	$oid =$_REQUEST["oid"];
	
	/*	ƴװSQL���			*/
	$sql = "SELECT oid,cx,cy from gis where oid='" . $oid . "'";	//�в�ѯ����
	$sqlall = "SELECT oid,cx,cy from gis";				//�޲�ѯ����

	foreach($dbh->query($sql) as $row)
	{
		//print_r($row);	//������;
		$circleoid = $row[oid];
		$circlecx = $row[cx];
		$circlecy = $row[cy];
		
		//���ɿμ����������Ҫ��xml�ļ�
		$circlexml = "<circle id='". $circleoid ."' cx='". $circlecx ."' cy='" . $circlecy ."' r='10' fill='#FFFFFF' stroke='#000000' />";
		//ƴװȫ����XML����
		$svgxml = $svgxml . $circlexml;	
	}
	
	//�����������˵�����
	echo $configXML;
   
	// �ͷ�PHP�����ݿ����ӣ����˴���պ�Oracle OCI8�����ͻ��˻���������
	$dbh=null;
}catch(PDOException $e){
	//��ʾ���ݿ����������Ϣ
	die("Error!: ".$e->getMessage()."<br/>");
}


/*	help
	����PHP PDO������֧�����ݿ��޹��ԣ�
	���Ӳ�ͬ���ݿ�ֻ���޸�dbms,���ܵ�ֵ��mysql/odi/mssql/postsql/odbc��
	Ĭ��������ǳ����ӣ������Ҫ���ݿⳤ���ӣ���Ҫ����һ��������array(PDO::ATTR_PERSISTENT => true) ���������
	$db=new PDO($dsn,$user,$pass,array(PDO::ATTR_PERSISTENT=>true));
	���ԣ�
		http://localhost/chd/DGGeo_PDO.php
		http://loclahost/chd/DBGeo_PDO.php?oid=1
		�������ô�����������Ӳ�����sql��䣬�������ݿ������Ϣ����
	Flex�����ʹ�ã�
		Flex�л�õ��ı�����echo�����
		����·��	http://localhost/chd/DGGeo_PDO.php
		���·��	DGGeo_PDO.php(swf�ļ���ͬһ��Ŀ¼)
*/
?>