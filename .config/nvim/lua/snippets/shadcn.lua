return {
  -- Shadcn Button
  s("Button", {
    t('<Button '), i(1, "variant='default'"), t('>'),
    t({ "", "  " }), i(2, "Button text"),
    t({ "", "</Button>" }),
  }),

  -- Shadcn Card
  s("Card", {
    t("<Card>"),
    t({ "", "  <CardHeader>", "" }),
    t("    <CardTitle>"), i(1, "Card title"), t("</CardTitle>"),
    t({ "", "    <CardDescription>" }),
    t("      "), i(2, "Card description"),
    t({ "", "    </CardDescription>", "" }),
    t("  </CardHeader>"),
    t({ "", "  <CardContent>", "" }),
    t("    "), i(3, "Card content"),
    t({ "", "  </CardContent>", "" }),
    t("</Card>"),
  }),

  -- Shadcn Dialog
  s("Dialog", {
    t("<Dialog open="), i(1, "open"), t(" onOpenChange="), i(2, "setOpen"), t(">"),
    t({ "", "  <DialogContent>", "" }),
    t("    <DialogHeader>"),
    t({ "", "      <DialogTitle>" }),
    t("        "), i(3, "Dialog title"),
    t({ "", "      </DialogTitle>", "" }),
    t("      <DialogDescription>"),
    t("        "), i(4, "Dialog description"),
    t({ "", "      </DialogDescription>", "" }),
    t("    </DialogHeader>"),
    t({ "", "    " }), i(5, "Dialog content"),
    t({ "", "  </DialogContent>", "" }),
    t("</Dialog>"),
  }),

  -- Shadcn Input
  s("Input", {
    t('<Input type="'), i(1, "text"), t('" placeholder="'), i(2, "Placeholder"), t('" />'),
  }),

  -- Shadcn Label
  s("Label", {
    t('<Label htmlFor="'), i(1, "input-id"), t('">'),
    i(2, "Label text"),
    t("</Label>"),
  }),

  -- Shadcn Select
  s("Select", {
    t("<Select>"),
    t({ "", "  <SelectTrigger>", "" }),
    t("    <SelectValue placeholder="), i(1, "'Select option'"), t(" />"),
    t({ "", "  </SelectTrigger>", "" }),
    t("  <SelectContent>"),
    t({ "", "    <SelectItem value=\""), i(2, "value1"), t("\">" }),
    i(3, "Option 1"),
    t({ "", "    </SelectItem>", "" }),
    t("    <SelectItem value=\""), i(4, "value2"), t("\">" }),
    i(5, "Option 2"),
    t({ "", "    </SelectItem>", "" }),
    t("  </SelectContent>"),
    t("</Select>"),
  }),

  -- Shadcn Tabs
  s("Tabs", {
    t("<Tabs defaultValue=\""), i(1, "tab1"), t("\">"),
    t({ "", "  <TabsList>", "" }),
    t("    <TabsTrigger value=\""), i(2, "tab1"), t("\">"),
    i(3, "Tab 1"),
    t("</TabsTrigger>"),
    t({ "", "    <TabsTrigger value=\""), i(4, "tab2"), t("\">" }),
    i(5, "Tab 2"),
    t("</TabsTrigger>"),
    t({ "", "  </TabsList>", "" }),
    t("  <TabsContent value=\""), i(6, "tab1"), t("\">"),
    t({ "", "    " }), i(7, "Tab 1 content"),
    t({ "", "  </TabsContent>", "" }),
    t("  <TabsContent value=\""), i(8, "tab2"), t("\">"),
    t({ "", "    " }), i(9, "Tab 2 content"),
    t({ "", "  </TabsContent>", "" }),
    t("</Tabs>"),
  }),

  -- Shadcn Table
  s("Table", {
    t("<Table>"),
    t({ "", "  <TableHeader>", "" }),
    t("    <TableRow>"),
    t("      <TableHead>"), i(1, "Header 1"), t("</TableHead>"),
    t("      <TableHead>"), i(2, "Header 2"), t("</TableHead>"),
    t({ "", "    </TableRow>", "" }),
    t("  </TableHeader>"),
    t({ "", "  <TableBody>", "" }),
    t("    <TableRow>"),
    t("      <TableCell>"), i(3, "Cell 1"), t("</TableCell>"),
    t("      <TableCell>"), i(4, "Cell 2"), t("</TableCell>"),
    t({ "", "    </TableRow>", "" }),
    t("  </TableBody>"),
    t("</Table>"),
  }),

  -- Shadcn Badge
  s("Badge", {
    t('<Badge variant="'), i(1, "default"), t('">'),
    i(2, "Badge text"),
    t("</Badge>"),
  }),

  -- Shadcn Switch
  s("Switch", {
    t("<Switch "),
    t("checked="), i(1, "checked"), t(" "),
    t("onCheckedChange="), i(2, "setChecked"), t(" />"),
  }),

  -- Shadcn Checkbox
  s("Checkbox", {
    t("<Checkbox "),
    t("checked="), i(1, "checked"), t(" "),
    t("onCheckedChange="), i(2, "setChecked"), t(" />"),
  }),

  -- Shadcn Textarea
  s("Textarea", {
    t('<Textarea placeholder="'), i(1, "Placeholder"), t('" />'),
  }),

  -- Shadcn Sheet
  s("Sheet", {
    t("<Sheet open="), i(1, "open"), t(" onOpenChange="), i(2, "setOpen"), t(">"),
    t({ "", "  <SheetContent>", "" }),
    t("    <SheetHeader>"),
    t({ "", "      <SheetTitle>" }),
    t("        "), i(3, "Sheet title"),
    t({ "", "      </SheetTitle>", "" }),
    t("      <SheetDescription>"),
    t("        "), i(4, "Sheet description"),
    t({ "", "      </SheetDescription>", "" }),
    t("    </SheetHeader>"),
    t({ "", "    " }), i(5, "Sheet content"),
    t({ "", "  </SheetContent>", "" }),
    t("</Sheet>"),
  }),

  -- Shadcn Dropdown Menu
  s("DropdownMenu", {
    t("<DropdownMenu>"),
    t({ "", "  <DropdownMenuTrigger>", "" }),
    i(1, "Trigger"),
    t({ "", "  </DropdownMenuTrigger>", "" }),
    t("  <DropdownMenuContent>"),
    t({ "", "    <DropdownMenuItem>" }),
    i(2, "Menu Item 1"),
    t({ "", "    </DropdownMenuItem>", "" }),
    t("    <DropdownMenuItem>"),
    i(3, "Menu Item 2"),
    t({ "", "    </DropdownMenuItem>", "" }),
    t("  </DropdownMenuContent>"),
    t("</DropdownMenu>"),
  }),

  -- Shadcn Avatar
  s("Avatar", {
    t("<Avatar>"),
    t({ "", "  <AvatarImage src=\""), i(1, "src"), t("\" />", "" }),
    t("  <AvatarFallback>"),
    i(2, "Fallback"),
    t({ "", "  </AvatarFallback>", "" }),
    t("</Avatar>"),
  }),

  -- Shadcn Progress
  s("Progress", {
    t('<Progress value="'), i(1, "50"), t('" />'),
  }),

  -- Shadcn Skeleton
  s("Skeleton", {
    t("<Skeleton className=\""), i(1, "h-4 w-[200px]"), t("\" />"),
  }),

  -- Shadcn Alert
  s("Alert", {
    t("<Alert>"),
    t({ "", "  <AlertTitle>" }),
    i(1, "Alert title"),
    t({ "", "  </AlertTitle>", "" }),
    t("  <AlertDescription>"),
    i(2, "Alert description"),
    t({ "", "  </AlertDescription>", "" }),
    t("</Alert>"),
  }),

  -- Shadcn Tooltip
  s("Tooltip", {
    t("<TooltipProvider>"),
    t({ "", "  <Tooltip>", "" }),
    t("    <TooltipTrigger>"),
    i(1, "Trigger"),
    t({ "", "    </TooltipTrigger>", "" }),
    t("    <TooltipContent>"),
    i(2, "Tooltip content"),
    t({ "", "    </TooltipContent>", "" }),
    t("  </Tooltip>"),
    t("</TooltipProvider>"),
  }),

  -- Shadcn Popover
  s("Popover", {
    t("<Popover>"),
    t({ "", "  <PopoverTrigger>", "" }),
    i(1, "Trigger"),
    t({ "", "  </PopoverTrigger>", "" }),
    t("  <PopoverContent>"),
    i(2, "Content"),
    t({ "", "  </PopoverContent>", "" }),
    t("</Popover>"),
  }),

  -- Shadcn Separator
  s("Separator", {
    t('<Separator className="'), i(1, "my-4"), t('" />'),
  }),

  -- Shadcn Scroll Area
  s("ScrollArea", {
    t("<ScrollArea className=\""), i(1, "h-[200px] w-[350px] rounded-md border p-4"), t("\">"),
    t({ "", "  " }), i(2, "Content"),
    t({ "", "</ScrollArea>" }),
  }),

  -- Shadcn Command
  s("Command", {
    t("<Command>"),
    t({ "", "  <CommandInput placeholder=\""), i(1, "Search"), t("\" />", "" }),
    t("  <CommandList>"),
    t({ "", "    <CommandGroup heading=\""), i(2, "Suggestions"), t("\">" }),
    t({ "", "      <CommandItem>" }),
    i(3, "Item 1"),
    t({ "", "      </CommandItem>", "" }),
    t("      <CommandItem>"),
    i(4, "Item 2"),
    t({ "", "      </CommandItem>", "" }),
    t("    </CommandGroup>"),
    t("  </CommandList>"),
    t("</Command>"),
  }),
}
