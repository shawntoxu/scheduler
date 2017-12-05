    private class ScheduleThread extends Thread {

        @Override
        public void run() {

            while (!DefaultSchedulerExecutor.this.closed.get()) {
                try {
                    List<Workflow> workflowList = DefaultSchedulerExecutor.this.workflowService.listAll(WorkflowStatus.OPEN);
                    List<Task> taskList = DefaultSchedulerExecutor.this.taskService.list(TaskStatus.OPEN);
                    // 当前调度时间
                    Date curDate = new Date(DefaultSchedulerExecutor.this.currentScheduleTime);
                    //处理工作流调度
                    if (workflowList != null) {

                        for (Workflow workflow : workflowList) {
                            Date scheduleTime = CrontabUtils.next(workflow.getCrontab(), workflow.getLastScheduleTime());

                            long diff = curDate.getTime() - scheduleTime.getTime();
                            if (diff >= 0) {
                                // 判断是否存在未完成的workflow（Inited和RUNNING），如有，则不触发调度; 被跳过，也持久化到数据库
                                boolean existUncompleted = DefaultSchedulerExecutor.this.workflowInstanceService.existUncompleted(workflow.getId());

                                WorkflowInstance instance = new WorkflowInstance();
                                instance.setScheduleTime(scheduleTime);
                                instance.setWorkflowId(workflow.getId());
                                if (!existUncompleted || ((workflow.getCanSkip() != null) && !workflow.getCanSkip())) {
                                    ConditionContext context = new ConditionContext(workflow, instance, null, null,
                                                                                    null, null);
                                    if (DefaultSchedulerExecutor.this.conditionChecker.satisfy(context)) {

                                        instance.setStatus(WorkflowInstanceStatus.INITED);

                                        try {
                                            DefaultSchedulerExecutor.this.workflowInstanceService.save(instance);
                                            DefaultSchedulerExecutor.this.workflowExecutor.submit(workflow, instance);
                                            DefaultSchedulerExecutor.this.workflowService.updateScheduleTime(workflow.getId(),
                                                                                                             scheduleTime);

                                        } catch (DuplicateKeyException e) {
                                            // ignored 重复了说明有被调度，调度时间应该更新
                                            DefaultSchedulerExecutor.this.workflowService.updateScheduleTime(workflow.getId(),
                                                                                                             scheduleTime);
                                        } catch (Exception e) {
                                            LOGGER.error(e.getMessage(), e);
                                        }
                                    }
                                } else {
                                    instance.setStatus(WorkflowInstanceStatus.SKIPPED);
                                    try {
                                        DefaultSchedulerExecutor.this.workflowInstanceService.save(instance);
                                        DefaultSchedulerExecutor.this.noticeService.workflowSkip(instance.getId(),
                                                                                                 scheduleTime);
                                        DefaultSchedulerExecutor.this.workflowService.updateScheduleTime(workflow.getId(),
                                                                                                         scheduleTime);
                                    } catch (DuplicateKeyException e) {
                                        // ignored 重复了说明有被调度，调度时间应该更新
                                        DefaultSchedulerExecutor.this.workflowService.updateScheduleTime(workflow.getId(),
                                                                                                         scheduleTime);
                                    } catch (Exception e) {
                                        LOGGER.error(e.getMessage(), e);
                                    }
                                }
                            }
                        }
                    }
                    //处理task调度
                    if (taskList != null) {
                        for (Task task : taskList) {
                            Date scheduleTime = CrontabUtils.next(task.getCrontab(), task.getLastScheduleTime());

                            long diff = curDate.getTime() - scheduleTime.getTime();
                            //当前时间大于下次调度时间，开始调度
                            if (diff >= 0) {
                                // 判断是否存在(相同taskId,存在schedule，状态未完成的)task（Inited和RUNNING），如有，则不触发调度; 被跳过，也持久化到数据库
                                boolean existUncompleted = DefaultSchedulerExecutor.this.taskInstanceService.existUncompletedScheduled(task.getId());

                                TaskInstance instance = new TaskInstance();
                                instance.setTaskId(task.getId());
                                instance.setScheduleTime(scheduleTime);
                                if (!existUncompleted || ((task.getCanSkip() != null) && !task.getCanSkip())) {
                                    ConditionContext context = new ConditionContext(null, null, null, task, instance,
                                                                                    null);
                                    if (DefaultSchedulerExecutor.this.conditionChecker.satisfy(context)) {
                                        instance.setStatus(TaskInstanceStatus.READY);
                                        try {
                                            DefaultSchedulerExecutor.this.taskInstanceService.save(instance);
                                            DefaultSchedulerExecutor.this.taskInstanceExecutor.submit(instance);
                                            DefaultSchedulerExecutor.this.taskService.updateLastScheduleTime(task.getId(),
                                                                                                             scheduleTime);
                                        } catch (DuplicateKeyException e) {
                                            // ignored 重复了说明有被调度，调度时间应该更新
                                            DefaultSchedulerExecutor.this.taskService.updateLastScheduleTime(task.getId(),
                                                                                                             scheduleTime);
                                        } catch (Exception e) {
                                            LOGGER.error(e.getMessage(), e);
                                        }
                                    }
                                } else {
                                    instance.setStatus(TaskInstanceStatus.SKIPPED);
                                    try {
                                        DefaultSchedulerExecutor.this.taskInstanceService.save(instance);
                                        DefaultSchedulerExecutor.this.noticeService.taskSkip(instance.getId(),
                                                                                             scheduleTime);
                                        DefaultSchedulerExecutor.this.taskService.updateLastScheduleTime(task.getId(),
                                                                                                         scheduleTime);
                                    } catch (DuplicateKeyException e) {
                                        // ignored 重复了说明有被调度，调度时间应该更新
                                        DefaultSchedulerExecutor.this.taskService.updateLastScheduleTime(task.getId(),
                                                                                                         scheduleTime);
                                    } catch (Exception e) {
                                        LOGGER.error(e.getMessage(), e);
                                    }
                                }
                            }
                        }
                    }

                    // 每隔 INTERVAL 时间调度一次
                    DefaultSchedulerExecutor.this.currentScheduleTime += INTERVAL;
                    // 持久化进度
                    try {
                        DefaultSchedulerExecutor.this.scheduleProgressService.saveCurrentScheduleTime(DefaultSchedulerExecutor.this.currentScheduleTime);
                    } catch (Exception e) {
                        LOGGER.error("Error when save the currentScheduleTime", e);
                    }
                    
                    //如果调度时间超过了当前时间，则设定为在当前时间没有到达调度时间时禁用线程
                    try {
                        if (System.currentTimeMillis() < DefaultSchedulerExecutor.this.currentScheduleTime) {
                            parkUntil(DefaultSchedulerExecutor.this.currentScheduleTime);
                        } else {
                    //将当前线程挂起1s后恢复
                            LockSupport.parkNanos(1000);
                        }
                    } catch (InterruptedException e) {
                        // ignored. maybe will close.
                    }
                } catch (Throwable e) {
                    // log for check the code
                    LOGGER.error("No Error should reach here, please check the code", e);
                }
            }
        }
    }