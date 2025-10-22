;; typescript
/**
 * Cloudflare Pages Function - {{_file_name_}}
 * @author {{_author_}}
 * @created {{_date_}}
 */

interface Env {
	// Add your environment bindings here
}

export const onRequest: PagesFunction<Env> = async (context) => {
	const { request, env, params } = context

	{{_cursor_}}

	return new Response(JSON.stringify({ success: true }), {
		headers: { 'Content-Type': 'application/json' },
	})
}
