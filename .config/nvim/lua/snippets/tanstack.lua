return {
  -- TanStack Query snippets
  s("useQuery", {
    t("const "), i(1, "queryKey"), t(" = useQuery({"),
    t({ "", "  queryKey: [" }), i(2, "'query'"), t("],"),
    t({ "", "  queryFn: async () => {", "" }),
    t("    const response = await fetch("), i(3, "url"), t(");"),
    t({ "", "    return response.json();", "" }),
    t("  },", ""),
    t({ "", "});" }),
  }),

  s("useMutation", {
    t("const "), i(1, "mutation"), t(" = useMutation({"),
    t({ "", "  mutationFn: async (" }), i(2, "variables"), t(") => {", ""),
    t("    const response = await fetch("), i(3, "url"), t(", {"),
    t({ "", "      method: 'POST'," }),
    t("      headers: { 'Content-Type': 'application/json' },"),
    t("      body: JSON.stringify("), i(4, "data"), t("),"),
    t({ "", "    });", "" }),
    t("    return response.json();"),
    t({ "", "  },", "" }),
    t("  onSuccess: ("), i(5, "data"), t(") => {", ""),
    t("    // Handle success"),
    t({ "", "  },", "" }),
    t("  onError: ("), i(6, "error"), t(") => {", ""),
    t("    // Handle error"),
    t({ "", "  },", "" }),
    t({ "", "});" }),
  }),

  s("useInfiniteQuery", {
    t("const "), i(1, "query"), t(" = useInfiniteQuery({"),
    t({ "", "  queryKey: [" }), i(2, "'query'"), t("],"),
    t({ "", "  queryFn: async ({ pageParam = " }), i(3, "0"), t(" }) => {", ""),
    t("    const response = await fetch("), i(4, "url"), t("?page=" .. pageParam);"),
    t("    return response.json();"),
    t({ "", "  },", "" }),
    t("  initialPageParam: "), i(5, "0"), t(","),
    t("  getNextPageParam: (lastPage, allPages, lastPageParam) => {"),
    t("    return lastPage.hasMore ? lastPageParam + 1 : undefined;"),
    t("  },"),
    t({ "", "});" }),
  }),

  -- TanStack Router snippets
  s("createFileRoute", {
    t("import { createFileRoute } from '@tanstack/react-router'"),
    t({ "", "" }),
    t("export const Route = createFileRoute('"), i(1, "path"), t("')({"),
    t({ "", "  component: " }), i(2, "Component"), t(","),
    t({ "", "})" }),
  }),

  s("createRouter", {
    t("import { createRouter, createRoute, createRootRoute } from '@tanstack/react-router'"),
    t({ "", "" }),
    t("const rootRoute = createRootRoute({"),
    t({ "", "  component: () => {" }),
    t({ "", "    return <Outlet />", "" }),
    t("  },"),
    t({ "", "})", "" }),
    t({ "", "" }),
    t("const indexRoute = createRoute({"),
    t({ "", "  getParentRoute: () => rootRoute,", "" }),
    t("  path: '/',"),
    t({ "", "  component: Index,", "" }),
    t("})"),
    t({ "", "" }),
    t("const routeTree = rootRoute.addChildren([indexRoute])"),
    t({ "", "" }),
    t("const router = createRouter({ routeTree })"),
  }),

  -- TanStack Table snippets
  s("useReactTable", {
    t("const table = useReactTable({"),
    t({ "", "  data: " }), i(1, "data"), t(","),
    t({ "", "  columns: " }), i(2, "columns"), t(","),
    t({ "", "  getCoreRowModel: getCoreRowModel(),", "" }),
    t({ "", "  getSortedRowModel: getSortedRowModel(),", "" }),
    t({ "", "  getFilteredRowModel: getFilteredRowModel(),", "" }),
    t({ "", "  getPaginationRowModel: getPaginationRowModel(),", "" }),
    t("  state: {"),
    t("    sorting: "), i(3, "sorting"), t(","),
    t("    globalFilter: "), i(4, "globalFilter"), t(","),
    t("  },"),
    t("  onSortingChange: setSorting,"),
    t("  onGlobalFilterChange: setGlobalFilter,"),
    t({ "", "})" }),
  }),

  s("columnHelper", {
    t("const columnHelper = createColumnHelper<"), i(1, "RowType"), t(">()"),
  }),

  s("defineColumn", {
    t("columnHelper.accessor('"), i(1, "field"), t("', {"),
    t({ "", "  header: '"), i(2, "Header"), t("',", "" }),
    t("  cell: (info) => info.getValue(),"),
    t("})"),
  }),
}
