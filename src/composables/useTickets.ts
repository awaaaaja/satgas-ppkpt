import { supabase } from '@/lib/supabase'

export interface Ticket {
  id: string
  ticket_number: string
  category: string
  title: string
  description: string
  reporter_name: string
  reporter_contact: string
  status: string
  priority: string
  pic_id: string | null
  access_token: string
  created_at: string
  updated_at: string
}

export interface TicketStatus {
  ticket_number: string
  status: string
  priority: string
  category: string
  title: string
  created_at: string
  updated_at: string
  pic: string | null
  updates: { note: string; status_to: string | null; created_at: string }[]
}

export interface CreateTicketInput {
  title: string
  description: string
  category: string
  reporterName?: string
  reporterContact?: string
}

export async function createTicket(input: CreateTicketInput) {
  const { data, error } = await supabase.rpc('create_ticket', {
    p_title: input.title,
    p_description: input.description,
    p_category: input.category,
    p_reporter_name: input.reporterName ?? '',
    p_reporter_contact: input.reporterContact ?? '',
  })
  if (error) throw error
  const row = Array.isArray(data) ? data[0] : data
  return row as { ticket_number: string; access_token: string }
}

export async function getTicketStatus(ticketNumber: string, accessToken: string) {
  const { data, error } = await supabase.rpc('get_ticket_status', {
    p_ticket_number: ticketNumber,
    p_access_token: accessToken,
  })
  if (error) throw error
  return data as TicketStatus | null
}

export async function listTickets() {
  const { data, error } = await supabase
    .from('tickets')
    .select('*')
    .order('created_at', { ascending: false })
  if (error) throw error
  return data as Ticket[]
}

export async function updateTicket(id: string, patch: Partial<Pick<Ticket, 'status' | 'priority' | 'pic_id'>>) {
  const { data, error } = await supabase.from('tickets').update(patch).eq('id', id).select()
  if (error) throw error
  return data
}

export async function addTicketUpdate(ticketId: string, note: string) {
  const { data, error } = await supabase
    .from('ticket_updates')
    .insert({ ticket_id: ticketId, note })
    .select()
  if (error) throw error
  return data
}