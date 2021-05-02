CREATE TABLE `alf_billing` (
  `sender` varchar(255) DEFAULT NULL,
  `reciever` varchar(255) DEFAULT NULL,
  `target_type` varchar(255) DEFAULT NULL,
  `target` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `description` longtext,
  `price` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
COMMIT;