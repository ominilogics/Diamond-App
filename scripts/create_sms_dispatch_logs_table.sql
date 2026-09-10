-- Create table for tracking Twilio SMS/WhatsApp dispatches and enforcing hourly rate limits
CREATE TABLE IF NOT EXISTS public.sms_dispatch_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    recipient_phone TEXT NOT NULL,
    delivery_method TEXT NOT NULL CHECK (delivery_method IN ('sms', 'whatsApp')),
    twilio_sid TEXT,
    status TEXT DEFAULT 'sent',
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index for high-performance rate-limit checking (user_id + created_at)
CREATE INDEX IF NOT EXISTS idx_sms_dispatch_logs_user_created 
ON public.sms_dispatch_logs (user_id, created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.sms_dispatch_logs ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view their own dispatch logs
CREATE POLICY "Users can view own sms logs" 
ON public.sms_dispatch_logs FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

-- Allow authenticated & service_role users to insert dispatch logs
CREATE POLICY "Service role and users can insert sms logs" 
ON public.sms_dispatch_logs FOR INSERT 
TO authenticated, service_role 
WITH CHECK (true);

-- Grant privileges to anon, authenticated, and service_role
GRANT ALL ON TABLE public.sms_dispatch_logs TO anon, authenticated, service_role;
