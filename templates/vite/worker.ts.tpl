;; typescript
/**
 * Cloudflare Worker - {{_file_name_}}
 * @author {{_author_}}
 * @created {{_date_}}
 */

export interface Env {
	// Add your environment bindings here
	// Example: DB: D1Database
}

export default {
	async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
		const url = new URL(request.url);

		{{_cursor_}}

		return new Response('Hello World!', {
			headers: { 'Content-Type': 'text/plain' },
		});
	},
} satisfies ExportedHandler<Env>;
