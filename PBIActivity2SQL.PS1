# Written by Mark Moore 05/12/2023
# This script will query the Power BI Activity Events, pull back the last 30 days of events and write them to a SQL Database.
#
# SQL Server connection and setup the SQL Client
# You will need to change the following line of code to Your actual SQL Server
#                                                               \/   \/    \/

$con = new-object System.Data.SqlClient.SqlConnection "Server=<Your SQL Server>;Pooling=false;Integrated Security=true"
$con.Open()

$cmd = $con.CreateCommand()


#
# If the Database does not exist create it.
#

$cmd.CommandText = 
"IF EXISTS 
(
  SELECT name FROM master.dbo.sysdatabases 
 WHERE name = N'PBIActivity'
 )
BEGIN
 SELECT 'Database Name already Exist' AS Message
END
ELSE
BEGIN
 CREATE DATABASE [PBIActivity]
 SELECT 'New Database is Created'
END
"
$rdr = $cmd.ExecuteReader()
$rdr.Read()
    $status = $rdr[0]
    $rdr.Close();

#
# If the table does not exist create it.
#

$cmd.CommandText =
"
BEGIN TRY
	USE [PBIActivity]
	CREATE TABLE [dbo].[PBIActivityLogs] 
	(
		[Id] char(255),
		[RecordType] char(255),
		[CreationTime] datetime2(7),
		[Operation] char(255),
		[OrganizationID] char(255),
		[UserType] char(255),
		[Workload] char(255),
		[UserID] char(255),
        [ClientIP] char(255),
		[Activity] char(255),
		[ItemName] char(255),
		[WorkSpaceName] char(255),
		[DatasetName] char(255),
		[ReportName] char(255),
		[CapacityId] char(255),
		[CapacityName] char(255),
		[WorkspaceId] char(255),
		[ObjectID] char(255),
		[DatasetID] char(255),
		[ReportId] char(255),
        [ArtifactId] char(255),
        [ArtifactName] char(255),
		[IsSuccess] char(255),
		[ReportType] char(255),
		[RequestId] char(255),
		[DistributionMethod] char(255),
        [ConsumptionMethod] char(255),
        [ArtifactKind] char(255)
)
END TRY
BEGIN CATCH  
    SELECT ERROR_MESSAGE() AS ErrorMessage;  
END CATCH;  
 
"

$rdr2 = $cmd.ExecuteReader()
$rdr2.Read()
    $status = $rdr2[0]

$rdr2.Close();
#write-host($status)

#
# Fore each record of the day being processed write the record to the database.
#
$day = 1
#30..1 |
#foreach 
while($day -lt 31)
{
    $Date = (((Get-Date).Date).AddDays(-$day))
    "$Date"
    $StartDate = (Get-Date -Date ($Date) -Format yyyy-MM-ddTHH:mm:ss)
    $EndDate = (Get-Date -Date ((($Date).AddDays(1)).AddMilliseconds(-1)) -Format yyyy-MM-ddTHH:mm:ss)
    
    $activities = Get-PowerBIActivityEvent -StartDateTime $StartDate -EndDateTime $EndDate -ResultType JsonString

    $records = $activities | ConvertFrom-Json
    $day = $day +1
    foreach( $record in $records)
    { 
        $id = $record.Id
        $recordtype = $record.RecordType
        $createtime = $record.CreationTime
        $operation = $record.Operation
        $orgid = $record.OrganizationId
        $usertype = $record.UserType
        #$userkey = $record.UserKey
        $workload = $record.Workload
        $userid = $record.UserId
        $clientip = $record.ClientIP
        $act = $record.Activity
        $itemname = $record.ItemName
        $workspace = $record.WorkSpaceName
        $dataset = $record.DatasetName
        $reportname = $record.ReportName
        $capcityid = $record.CapacityID
        $capacityname = $record.CapacityName
        $workspaceid = $record.WorksapceId
        $object = $record.ObjectId
        $datasetid = $record.DatasetId
        $reportid = $record.ReportId
        $artifactid = $record.ArtifactId
        $artifactname = $record.ArtifactName
        $issuccess = $record.IsSucess
        $reporttype = $record.ReportType
        $requestid = $record.RequestId
        $distributionmethod = $record.DistributionMethod
        $consumptionmethod = $record.ConsumptionMethod
        $artifactkind = $record.ArtifactKind

        $cmd.CommandText = " 
            INSERT INTO [dbo].[PBIActivityLogs] 
            ([Id],
	    	[RecordType],
		    [CreationTime],
    		[Operation],
	    	[OrganizationID],
		    [UserType],
    		[Workload],
	    	[UserID],
            [ClientIP],
    		[Activity],
	    	[ItemName],
		    [WorkSpaceName],
    		[DatasetName],
	    	[ReportName],
		    [CapacityId],
    		[CapacityName],
	    	[WorkspaceId],
		    [ObjectID],
    		[DatasetID],
    		[ReportId],
            [ArtifactId],
            [ArtifactName],
    		[IsSuccess],
    		[ReportType],
    		[RequestId],
    		[DistributionMethod],
            [ConsumptionMethod],
            [ArtifactKind]) 
        VALUES 
           ('$Id',
            '$recordtype',
            '$createtime',
            '$operation',
            '$orgid',
            '$usertype',
            '$workload',
            '$userid',
            '$clientip',
            '$act',
            '$itemname',
            '$workspace',
            '$dataset',
            '$reportname',
            '$capcityid',
            '$capacityname',
            '$workspaceid',
            '$object',
            '$datasetid',
            '$reportid',
            '$artifactid',
            '$artifactname',
            '$issuccess',
            '$reporttype',
            '$requestid',
            '$distributionmethod',
            '$consumptionmethod',
            '$artifactkind')  "

    $rdr3 = $cmd.ExecuteReader()
    $rdr3.Read()
        $status = $rdr3[0]
        $rdr3.Close();

    }
}
