import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});


type CreateTaskBody = {
  application_id?: string;
  task_type?: "call" | "email" | "review" | string;
  due_at?: string;
};

const ALLOWED_TYPES = ["call", "email", "review"] as const;

// Helper: CORS headers (optional but nice if you call from browser)
const corsHeaders: HeadersInit = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request): Promise<Response> => {
  // Handle preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { status: 200, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  let body: CreateTaskBody;
  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ error: "Invalid JSON body" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const { application_id, task_type, due_at } = body;

  // Basic validation
  if (!application_id || !task_type || !due_at) {
    return new Response(
      JSON.stringify({
        error: "application_id, task_type and due_at are required",
      }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  if (!ALLOWED_TYPES.includes(task_type as any)) {
    return new Response(
      JSON.stringify({ error: "task_type must be one of: call, email, review" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const dueDate = new Date(due_at);
  if (Number.isNaN(dueDate.getTime())) {
    return new Response(
      JSON.stringify({ error: "due_at must be a valid ISO timestamp" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const now = new Date();
  if (dueDate <= now) {
    return new Response(
      JSON.stringify({ error: "due_at must be in the future" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    // Insert into tasks table (service role bypasses RLS)
    const { data, error } = await supabase
      .from("tasks")
      .insert({
        application_id,
        type: task_type,
        due_at,
        status: "pending",
      })
      .select("id")
      .single();

    if (error || !data) {
      console.error("Failed to insert task:", error);
      return new Response(
        JSON.stringify({ error: "Failed to create task" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const taskId = data.id as string;

    // Emit a broadcast-style event via events table
    // (your Realtime client can subscribe to this table)
    await supabase.from("events").insert({
      type: "task.created",
      payload: { task_id: taskId, application_id, task_type, due_at },
    });

    return new Response(
      JSON.stringify({ success: true, task_id: taskId }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (e) {
    console.error("Unhandled error:", e);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
