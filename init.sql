
SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for agent
-- ----------------------------
DROP TABLE IF EXISTS `agent`;
CREATE TABLE `agent` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `ip` varchar(100) NOT NULL,
  `team_id` bigint(20) NOT NULL DEFAULT '0',
  `alive` tinyint(1) NOT NULL DEFAULT '1',
  `enable` tinyint(1) NOT NULL DEFAULT '1'  COMMENT '0 下线 1 上线',
  `version` varchar(20) DEFAULT NULL,
  `upgrade_task_id` bigint(20) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `INDEX_USERNAME` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COMMENT='机器表';

-- ----------------------------
-- Table structure for attempt
-- ----------------------------
DROP TABLE IF EXISTS `attempt`;
CREATE TABLE `attempt` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `task_id` bigint(20) NOT NULL COMMENT '所属任务id',
  `instance_id` bigint(20) NOT NULL COMMENT '任务的一次调度',
  `agent_id` bigint(20) DEFAULT NULL COMMENT '执行机器',
  `transaction_id` bigint(20) DEFAULT NULL COMMENT 'agent事务id',
  `status` tinyint(3) NOT NULL COMMENT '1运行中，10运行成功，20失败，30取消运行,40未知的结束状态',
  `active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否活跃',
  `return_value` int(11) DEFAULT NULL COMMENT '返回值',
  `output` longtext COMMENT '任务的输出',
  `start_time` datetime DEFAULT NULL COMMENT '实际开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `duration` bigint(20) DEFAULT NULL COMMENT '运行时间(单位：毫秒)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_instance` (`instance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=184817 DEFAULT CHARSET=utf8 COMMENT='作业执行表';

-- ----------------------------
-- Table structure for schedule_progress
-- ----------------------------
DROP TABLE IF EXISTS `schedule_progress`;
CREATE TABLE `schedule_progress` (
  `id` int(11) NOT NULL,
  `current_schedule_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '当前调度进度',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for task
-- ----------------------------
DROP TABLE IF EXISTS `task`;
CREATE TABLE `task` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '任务名称',
  `owner` bigint(20) NOT NULL COMMENT '任务的拥有者',
  `type` tinyint(3) NOT NULL DEFAULT '1' COMMENT '作业的类型',
  `crontab` varchar(100) DEFAULT '' COMMENT 'crontab表达式',
  `command` text NOT NULL COMMENT '命令',
  `agent_id` bigint(20) DEFAULT NULL COMMENT 'host id',
  `status` tinyint(3) NOT NULL DEFAULT '1' COMMENT '任务的状态 1:正常2：挂起3：删除',
  `can_skip` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否可以被跳过',
  `last_status_dependency` tinyint(3) NOT NULL DEFAULT '1' COMMENT '上一次调度的状态依赖',
  `timeout` int(11) NOT NULL DEFAULT '60' COMMENT '执行超期时间（分）',
  `retry_times` int(11) NOT NULL DEFAULT '0' COMMENT '重试次数',
  `description` varchar(1024) DEFAULT NULL COMMENT '对该任务的描述',
  `last_schedule_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `attachment` varchar(200) DEFAULT NULL COMMENT '任务文件',
  `attachment_version` bigint(20) DEFAULT NULL COMMENT '任务文件版本',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8 COMMENT='任务表';

-- ----------------------------
-- Table structure for task_authority
-- ----------------------------
DROP TABLE IF EXISTS `task_authority`;
CREATE TABLE `task_authority` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `task_id` bigint(20) NOT NULL,
  `mode` tinyint(3) NOT NULL DEFAULT '1' COMMENT '0不可读不可写，1只读，2读写',
  `follow` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1关注2不关注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='权限表';

-- ----------------------------
-- Table structure for task_instance
-- ----------------------------
DROP TABLE IF EXISTS `task_instance`;
CREATE TABLE `task_instance` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `task_id` bigint(20) NOT NULL COMMENT '所属任务id',
  `workflow_instance_id` bigint(20) DEFAULT NULL COMMENT '对应的工作流实例',
  `status` tinyint(3) NOT NULL COMMENT '1初始，2运行中，3成功，4失败',
  `schedule_time` datetime DEFAULT NULL COMMENT '预计调度时间（只有task被定时调度时才会有这个字段，手工触发和workflow调度都不设置该字段）',
  `start_time` datetime DEFAULT NULL COMMENT '实际开始的时间',
  `end_time` datetime DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `INDEX_TASKID_SCHEDULERTIME` (`task_id`,`schedule_time`)
) ENGINE=InnoDB AUTO_INCREMENT=218773 DEFAULT CHARSET=utf8 COMMENT='作业调度表';

-- ----------------------------
-- Table structure for team
-- ----------------------------
DROP TABLE IF EXISTS `team`;
CREATE TABLE `team` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'team名称',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COMMENT='团队表';

-- ----------------------------
-- Table structure for team_workflow_instance_status
-- ----------------------------
DROP TABLE IF EXISTS `team_workflow_instance_status`;
CREATE TABLE `team_workflow_instance_status` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `team_id` bigint(20) NOT NULL COMMENT '所属team id',
  `workflow_id` bigint(20) NOT NULL,
  `workflow_instance_id` bigint(20) NOT NULL COMMENT '所属任务id',
  `status` tinyint(3) NOT NULL COMMENT '1初始，2运行中，3成功，4失败',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `INDEX_TEAMID_WORKFLOWINSTANCEID` (`team_id`,`workflow_instance_id`),
  KEY `INDEX_TEAMID_WORKFLOWID` (`team_id`,`workflow_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='公共工作流的每个team的调度表';

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '用户名，可采用邮箱前缀',
  `password` varchar(100) DEFAULT NULL COMMENT '密码',
  `email` varchar(255) NOT NULL DEFAULT '' COMMENT '邮件',
  `telephone` varchar(100) DEFAULT NULL COMMENT '电话号码',
  `token` varchar(100) DEFAULT NULL COMMENT 'API token',
  `team_id` bigint(20) DEFAULT NULL COMMENT '团队ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `INDEX_USERNAME` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8 COMMENT='用户表';

-- ----------------------------
-- Table structure for workflow
-- ----------------------------
DROP TABLE IF EXISTS `workflow`;
CREATE TABLE `workflow` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '名称',
  `owner` bigint(20) NOT NULL COMMENT '拥有者',
  `crontab` varchar(100) DEFAULT '' COMMENT 'crontab表达式',
  `status` tinyint(3) NOT NULL DEFAULT '1' COMMENT '状态 1:正常2：挂起3：删除',
  `can_skip` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否可以被跳过',
  `last_status_dependency` tinyint(3) NOT NULL DEFAULT '1' COMMENT '上一次调度的状态依赖',
  `common` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1公共的，0私有的',
  `timeout` int(11) NOT NULL DEFAULT '60' COMMENT '执行超期时间（分）',
  `description` varchar(1024) DEFAULT NULL COMMENT '描述',
  `last_schedule_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COMMENT='工作流表';

-- ----------------------------
-- Table structure for workflow_authority
-- ----------------------------
DROP TABLE IF EXISTS `workflow_authority`;
CREATE TABLE `workflow_authority` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `workflow_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `mode` tinyint(3) NOT NULL COMMENT '0不可读不可写，1只读，2读写',
  `follow` tinyint(1) NOT NULL COMMENT '1关注2不关注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='工作流权限表';

-- ----------------------------
-- Table structure for workflow_detail
-- ----------------------------
DROP TABLE IF EXISTS `workflow_detail`;
CREATE TABLE `workflow_detail` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `workflow_id` bigint(20) NOT NULL COMMENT 'workflow id',
  `task_id` bigint(20) NOT NULL COMMENT 'task id',
  `timeout` int(11) NOT NULL DEFAULT '60' COMMENT '执行超期时间（分）',
  `retry_times` int(11) NOT NULL DEFAULT '0' COMMENT '重试次数',
  `delay` int(11) NOT NULL DEFAULT '0' COMMENT '较调度时间延迟的分钟数',
  `last_status_dependency` tinyint(3) NOT NULL DEFAULT '1' COMMENT '上一次调度的状态依赖',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for workflow_instance
-- ----------------------------
DROP TABLE IF EXISTS `workflow_instance`;
CREATE TABLE `workflow_instance` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `workflow_id` bigint(20) NOT NULL COMMENT '所属任务id',
  `status` tinyint(3) NOT NULL COMMENT '(1, "新建"),(10, "运行中"),(20, "运行成功"),(30, "运行失败")(40, "取消运行")(50, "被跳过")(60, "未知的结束状态")',
  `schedule_time` datetime DEFAULT NULL COMMENT '预计调度时间',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL COMMENT '实际触发时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `INDEX_WORKFLOWID_SCHEDULERTIME` (`workflow_id`,`schedule_time`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='工作流调度表';

-- ----------------------------
-- Table structure for workflow_task_dependency
-- ----------------------------
DROP TABLE IF EXISTS `workflow_task_dependency`;
CREATE TABLE `workflow_task_dependency` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `workflow_detail_id` bigint(20) NOT NULL COMMENT 'workflow detail id',
  `dependency_task_id` bigint(20) NOT NULL COMMENT 'dependency task id',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;



INSERT INTO `schedule_progress` (`id`) VALUES (1);
INSERT INTO `team` (`id`,`name`,`create_time`,`update_time`) VALUES (1,'admin',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
INSERT INTO `team` (`id`,`name`,`create_time`,`update_time`) VALUES (2,'platform',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
INSERT INTO `user` (`id`,`name`,`password`,`email`,`telephone`,`team_id`) VALUES (1,'admin','21232f297a57a5a743894a0e4a801fc3','platform@ndpmedia.com','15928776354',1);
INSERT INTO `user` (`id`,`name`,`password`,`email`,`telephone`,`team_id`) VALUES (2,'monitor','08b5411f848a2581a41672a759c87380','platform@ndpmedia.com','15921096896',2);
-- ----------------------------
-- View structure for workflow_task_instance
-- ----------------------------
-- 哪个用户有权限创建就用那个用户创建view
DROP VIEW IF EXISTS `workflow_task_instance`;
CREATE ALGORITHM=UNDEFINED DEFINER=`yscheduler`@`%` SQL SECURITY invoker VIEW `workflow_task_instance` 
AS select 
`task_instance`.`id` AS `id`,`task`.`name` AS `name`,1 AS `type`,`task_instance`.`task_id` AS `workflow_task_id`,`task`.`owner` AS `owner`,`task_instance`.`status` AS `status`,`task_instance`.`schedule_time` AS `schedule_time`,`task_instance`.`start_time` AS `start_time`,`task_instance`.`end_time` AS `end_time`,`task_instance`.`create_time` AS `create_time`,`task_instance`.`update_time` AS `update_time` 
 from (`task_instance` left join `task` on((`task_instance`.`task_id` = `task`.`id`))) 
  where (`task_instance`.`schedule_time` is not null and `task`.`name` not like '%_heartbeat%') 
union all
select `workflow_instance`.`id` AS `id`,`workflow`.`name` AS `name`,2 AS `2`,`workflow_instance`.`workflow_id` AS `task_workflow_id`,`workflow`.`owner` AS `owner`,`workflow_instance`.`status` AS `status`,`workflow_instance`.`schedule_time` AS `schedule_time`,`workflow_instance`.`start_time` AS `start_time`,`workflow_instance`.`end_time` AS `end_time`,`workflow_instance`.`create_time` AS `create_time`,`workflow_instance`.`update_time` AS `update_time` 
 from (`workflow_instance` left join `workflow` on((`workflow_instance`.`workflow_id` = `workflow`.`id`))) 
  where (`workflow_instance`.`schedule_time` is not null) ;


优化 ：
  将union 改为 union all 
   union会对数据做一个distanct的动作

   数据量 936152
   
