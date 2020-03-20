/* from Linux kernel source (GPL2): */

/* If CLONE_SYSVSEM is set, establish sharing of SEM_UNDO state between
 * parent and child tasks.
 */

int copy_semundo(unsigned long clone_flags, struct task_struct *tsk)
{
        struct sem_undo_list *undo_list;
        int error;

        if (clone_flags & CLONE_SYSVSEM) {
                error = get_undo_list(&undo_list);
                if (error)
                        return error;
                refcount_inc(&undo_list->refcnt);
                tsk->sysvsem.undo_list = undo_list;
        } else
                tsk->sysvsem.undo_list = NULL;

        return 0;
}
