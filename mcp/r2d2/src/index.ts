#!/usr/bin/env node

import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createR2d2Server } from "./tools.js";

const server = await createR2d2Server();
const transport = new StdioServerTransport();
await server.connect(transport);
