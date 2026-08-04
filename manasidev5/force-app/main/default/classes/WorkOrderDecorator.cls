public class WorkOrderDecorator {
    public static final String STATUS_CANCELED = 'Canceled';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_NOTCOMPLETED = 'Cannot Complete';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_CATEGORY_CANCELED = 'Canceled';
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_ON_HOLD = 'On Hold';
    public static final Set<String> CLOSED_JOB_STATUS = new Set<String>{WorkOrderDecorator.STATUS_CATEGORY_CANCELED, WorkOrderDecorator.STATUS_NOTCOMPLETED, WorkOrderDecorator.STATUS_COMPLETED, WorkOrderDecorator.STATUS_CLOSED};
    public static final List<String> OPEN_STATUSES_CATEGORTIES =  new List<String>{
            WorkOrderDecorator.STATUS_NEW,
            WorkOrderDecorator.STATUS_IN_PROGRESS,
            WorkOrderDecorator.STATUS_ON_HOLD

    };


}