;; typescript
/**
 * {{_camel_case_file_}} Hook
 * @author {{_author_}}
 * @created {{_date_}}
 */

import { useState, useEffect } from 'react'

interface Use{{_camel_case_file_}}Options {
	{{_cursor_}}
}

export function use{{_camel_case_file_}}(options?: Use{{_camel_case_file_}}Options) {
	const [data, setData] = useState()

	useEffect(() => {
		// Hook logic here
	}, [])

	return {
		data,
	}
}
