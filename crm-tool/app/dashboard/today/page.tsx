// following directory as per assignment

// app/dashboard/today/page.tsx


"use client";

import { useMemo } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/lib/supabaseClient";

type Task = {
  id: string;
  type: "call" | "email" | "review";
  application_id: string;
  due_at: string;
  status: string;
};

export default function TodayDashboardPage() {
  const queryClient = useQueryClient();

  const todayRange = useMemo(() => {
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date();
    end.setHours(23, 59, 59, 999);
    return { from: start.toISOString(), to: end.toISOString() };
  }, []);

  const tasksQuery = useQuery({
    queryKey: ["tasks", "today"],
    queryFn: async (): Promise<Task[]> => {
      const { data, error } = await supabase
        .from("tasks")
        .select("id, type, application_id, title, due_at, status") // added title
        .eq("status", "pending")
        .gte("due_at", todayRange.from)
        .lte("due_at", todayRange.to);

      if (error) throw error;
      return data ?? [];
    },
  });


  const markCompleteMutation = useMutation({
    mutationFn: async (taskId: string) => {
      const { error } = await supabase
        .from("tasks")
        .update({ status: "completed", updated_at: new Date().toISOString() })
        .eq("id", taskId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks", "today"] });
    },
  });

  const loading = tasksQuery.isLoading;
  const error = tasksQuery.isError ? (tasksQuery.error as Error) : null;
  const tasks = tasksQuery.data ?? [];

  const formatDateTime = (iso: string) =>
    new Date(iso).toLocaleString(undefined, {
      hour12: false,
      year: "numeric",
      month: "short",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
    });

  const typeBadgeClass = (type: Task["type"]) =>
    type === "call"
      ? "badge badge-type-call"
      : type === "email"
        ? "badge badge-type-email"
        : "badge badge-type-review";

  return (
    <div className="main-shell">
      <div className="card">
        <div className="card-header">
          <div>
            <h1 className="card-title">Today&apos;s Tasks</h1>
            <p className="card-subtitle">
              All open follow-ups due in your pipeline today.
            </p>
          </div>
        </div>

        {loading && <div className="empty-state">Loading today&apos;s tasks…</div>}

        {error && (
          <div className="empty-state">
            Error loading tasks: {error.message}
          </div>
        )}

        {!loading && !error && (
          <>
            <div className="table-wrapper">
              {tasks.length === 0 ? (
                <div className="empty-state">
                  No pending tasks due today. You&apos;re all caught up.
                </div>
              ) : (
                <table className="tasks-table">
                  <thead>
                    <tr>
                      <th>Type</th>
                      <th>Title</th>        {/* was Application */}
                      <th>Due at</th>
                      <th>Status</th>
                      <th />
                    </tr>
                  </thead>
                  <tbody>
                    {tasks.map((task) => (
                      <tr key={task.id}>
                        <td>
                          <span className={typeBadgeClass(task.type)}>
                            {task.type.toUpperCase()}
                          </span>
                        </td>
                        <td>{task.title || "Untitled task"}</td>   {/* show title here */}
                        <td>{formatDateTime(task.due_at)}</td>
                        <td>
                          <span className="badge badge-status-pending">
                            {task.status}
                          </span>
                        </td>
                        <td>
                          <button
                            className="btn-primary"
                            onClick={() => markCompleteMutation.mutate(task.id)}
                            disabled={
                              markCompleteMutation.isPending ||
                              task.status === "completed"
                            }
                          >
                            {task.status === "completed" ? "Completed" : "Mark Complete"}
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>

                </table>
              )}
            </div>

            <div className="status-row">
              Showing <span>{tasks.length}</span> task
              {tasks.length === 1 ? "" : "s"} due today.
            </div>
          </>
        )}
      </div>
    </div>
  );
}
