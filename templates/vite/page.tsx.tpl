;; typescriptreact
/**
 * {{_camel_case_file_}} Page Component
 * @author {{_author_}}
 * @created {{_date_}}
 */

import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/{{_file_name_}}')({
	component: {{_camel_case_file_}}Page,
})

function {{_camel_case_file_}}Page() {
	{{_cursor_}}

	return (
		<div className="container mx-auto px-4 py-8">
			<h1 className="text-3xl font-bold mb-6">{{_camel_case_file_}}</h1>

		</div>
	)
}
