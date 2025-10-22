;; typescript
/**
 * {{_camel_case_file_}} API Client
 * @author {{_author_}}
 * @created {{_date_}}
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

// API Types
interface {{_camel_case_file_}}Data {
	{{_cursor_}}
}

// Query Keys
export const {{_file_name_}}Keys = {
	all: ['{{_file_name_}}'] as const,
	lists: () => [...{{_file_name_}}Keys.all, 'list'] as const,
	list: (filters: string) => [...{{_file_name_}}Keys.lists(), { filters }] as const,
	details: () => [...{{_file_name_}}Keys.all, 'detail'] as const,
	detail: (id: string) => [...{{_file_name_}}Keys.details(), id] as const,
}

// API Functions
async function fetch{{_camel_case_file_}}(id: string): Promise<{{_camel_case_file_}}Data> {
	const response = await fetch(`/api/{{_file_name_}}/${id}`)
	if (!response.ok) throw new Error('Failed to fetch {{_file_name_}}')
	return response.json()
}

async function create{{_camel_case_file_}}(data: Partial<{{_camel_case_file_}}Data>): Promise<{{_camel_case_file_}}Data> {
	const response = await fetch('/api/{{_file_name_}}', {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(data),
	})
	if (!response.ok) throw new Error('Failed to create {{_file_name_}}')
	return response.json()
}

// Hooks
export function use{{_camel_case_file_}}(id: string) {
	return useQuery({
		queryKey: {{_file_name_}}Keys.detail(id),
		queryFn: () => fetch{{_camel_case_file_}}(id),
	})
}

export function useCreate{{_camel_case_file_}}() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: create{{_camel_case_file_}},
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: {{_file_name_}}Keys.lists() })
		},
	})
}
