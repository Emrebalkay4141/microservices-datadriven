
--DROP QUEUE
BEGIN
  DBMS_AQADM.STOP_QUEUE(queue_name => 'ORDERQUEUE');
  DBMS_AQADM.DROP_QUEUE(queue_name => 'ORDERQUEUE');
  DBMS_AQADM.DROP_QUEUE_TABLE(queue_table => 'ORDERQUEUETABLE');
END;

BEGIN
  DBMS_AQADM.STOP_QUEUE(queue_name => 'INVENTORYQUEUE');
  DBMS_AQADM.DROP_QUEUE(queue_name => 'INVENTORYQUEUE');
  DBMS_AQADM.DROP_QUEUE_TABLE(queue_table => 'INVENTORYQUEUETABLE');
END;