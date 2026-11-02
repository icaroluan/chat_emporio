# Customer Service Agent — Empório da Música

A Python prototype for text-based customer service at the fictional store Empório da Música. The agent retrieves products, prices, stock levels, promotions, orders, and store policies while maintaining context across messages.

Users interact through the terminal. This implementation focuses on the agent workflow, integration with its data sources, and visibility into which tools were executed.

## Features

- Customer service in Portuguese, with the persona and scope defined in the prompt.
- Model-driven tool selection based on the question and conversation history.
- Parameterized PostgreSQL queries, without unrestricted SQL generation by the model.
- Access to the store manual, converted from PDF to Markdown.
- Persistent sessions and messages.
- Status output showing executed tools, returned row counts, and execution times.
- Handling of expected API, query, and persistence failures.

The prompt instructs the agent to reject out-of-scope topics and stay grounded in its sources. These behaviors must be evaluated through conversations; they are not absolute guarantees provided by the model.

## Requirements

- Git to clone the repository.
- Python 3.12 or later.
- uv for environment and dependency management.
- Docker with Docker Compose and a running container engine.
- A Gemini API key and access to the configured model.
- Internet access to install dependencies, download the PostgreSQL image, and call the API.

## Tested Environment

I tested the application on **Windows 11**, using **uv** to manage and run the project and **Visual Studio Code** for development and debugging. The walkthrough below uses PowerShell and reflects that environment.

I have not tested the project on Linux. This README therefore provides a Windows walkthrough only.

Run the setup commands from the repository root after cloning the project.

## Setup and Execution

### 1. Clone the repository

Repository: [icaroluan/chat_emporio](https://github.com/icaroluan/chat_emporio).

```powershell
git clone https://github.com/icaroluan/chat_emporio.git
cd chat_emporio
```

### 2. Prepare the environment

Install the project dependencies:

```powershell
uv sync --locked
```

If `.env` does not exist yet, copy the example file.

**Windows — PowerShell:**

```powershell
Copy-Item .env.example .env
```

Do not overwrite an existing configured `.env`. Set the values for your environment:

```dotenv
POSTGRES_DB=emporio
POSTGRES_USER=emporio
POSTGRES_PASSWORD=troque_esta_senha
POSTGRES_PORT=5433

DATABASE_URL=postgresql://emporio:troque_esta_senha@localhost:5433/emporio
GEMINI_API_KEY=SUA_CHAVE_AQUI
GEMINI_MODEL=gemini-3.5-flash-lite
CHAT_PROMPT_PATH=src/prompts/system_prompt.md
STORE_MANUAL_PATH=src/data/politicas_da_loja.pdf
```

Replace the example password and API key with your own values. `DATABASE_URL` must match the username, password, port, and database configured in Compose. Special characters in the password require appropriate URL encoding. The application uses `GEMINI_API_KEY` for the API key.

Relative prompt and manual paths are resolved from the project root. Do not commit `.env` to version control.

### 3. Start PostgreSQL

The Compose file is located in `scripts/`, and the initialization files are in `sqls/`. The SQL source paths in Compose must be `../sqls/01_schema.sql` and `../sqls/02_seed.sql`.

```powershell
docker compose --env-file .env -f scripts/docker-compose.yaml up -d
```

Check the service and wait until it is healthy:

```powershell
docker compose --env-file .env -f scripts/docker-compose.yaml ps
```

To follow initialization logs:

```powershell
docker compose --env-file .env -f scripts/docker-compose.yaml logs -f postgres
```

Press `Ctrl+C` to stop following the logs. The container keeps running.

When an empty volume is initialized for the first time, the scripts create eight tables in the `public` schema and insert the 191 records from the CSV files. The chat tables start empty. Data remains in the volume across restarts. Changing an SQL file after volume initialization does not automatically rerun its data load.

Python runs outside the container and connects to the database at `localhost:5433`. Only PostgreSQL runs in Docker.

### 4. Chat with the agent

```powershell
uv run python chat_interation.py
```

Type a question and press Enter. For example, these prompts use Portuguese, the store's service language:

```text
Quais violões disponíveis custam até R$ 1.000?
Desses, qual é o mais barato?
Qual é a política de troca da loja?
```

Type `sair` to exit. The CLI keeps one active session per execution. Starting without an existing session identifier creates a new conversation when the first message is processed.

To resume a saved conversation, replace `UUID_DA_SESSAO` with its session UUID:

```powershell
uv run python chat_interation.py --session-id UUID_DA_SESSAO
```

To test customer details and orders for customer 3:

```powershell
uv run python chat_interation.py --customer-id 3
```

These arguments can be combined to resume a session with the same test identity. `--customer-id` only simulates the customer's identity; it is not authentication. Without it, the customer and order tools report that the customer is not authenticated. Product searches do not require this argument.

For detailed tool logs:

```powershell
uv run python chat_interation.py --verbose-tools
```

### 5. Stop the database

```powershell
docker compose --env-file .env -f scripts/docker-compose.yaml down
```

This removes the container while preserving the data volume.

## Project Structure

I defined the project\'s directory structure and organized the files by responsibility.\n\n| Path | Responsibility |
|---|---|
| `chat_interation.py` | Terminal conversation entry point |
| `config/config.py` | Environment variables and path resolution |
| `services/chat_google.py` | Gemini integration, conversation context, and tools |
| `services/postgres_service.py` | Sessions, messages, and PostgreSQL access |
| `src/prompts/system_prompt.md` | Persona, behavior, sources, and rules |
| `src/data/politicas_da_loja.pdf` | Manual used by the agent |
| `scripts/docker-compose.yaml` | PostgreSQL service and SQL file mounts |
| `sqls/01_schema.sql` | Schema, relationships, indexes, and triggers |
| `sqls/02_seed.sql` | Initial data from the CSV files |
| `examples/` | Actual conversations used for evaluation |

## Solution Workflow

I first defined the path of a message: identify the session, retrieve context, consult the sources when needed, and persist the completed interaction. The conversation can continue with the same identifier until the user ends the execution.

```mermaid
flowchart TD
    A[Start application] --> B[Load configuration and convert manual]
    B --> C[Receive message]
    C --> S[Read prompt and validate input]
    S --> D{Session provided?}
    D -->|No| E[Create database session]
    D -->|Yes| F[Check that session exists]
    E --> G[Retrieve history]
    F --> G
    G --> H[Send context and message to Gemini]
    H --> I{Does model request tools?}
    I -->|Yes| J{Required source}
    J -->|Operational data| K[Execute parameterized SELECT]
    J -->|Policies| L[Retrieve Markdown manual]
    K --> M[Log execution and return result]
    L --> M
    M --> H
    I -->|Final response| N[Save question and answer in a transaction]
    N --> O[Display response and metrics]
    O --> P{Continue conversation?}
    P -->|Yes| C
    P -->|No| Q[Exit CLI and retain history]
    H -->|Failure or limit| R[Display error status]
    R --> C
```

This diagram shows the main loop. Database and file errors can also interrupt processing. The prompt is read on every turn before creating or retrieving the session; the manual is converted only when the instance is initialized.

The session is created before the API call. The question and answer are saved together only after a complete text response is obtained. A failure can therefore leave an empty session. An empty history is valid for a new conversation.

## Technical Decisions

### Function calling with the Google SDK

I chose to use the Google SDK directly, without an additional agent framework. For this prototype, this makes the workflow easy to follow with few layers: the model receives tool descriptions, selects functions and arguments, and Python executes the queries.

I separated tools by purpose to make access to each source explicit. A question may require no query or involve several tools, such as retrieving order items and then fetching product details.

| Tool | Purpose |
|---|---|
| `consultar_categorias` | Retrieve catalog categories |
| `consultar_produtos` | Search products by name, category, maximum price, or ID |
| `consultar_promocoes` | Retrieve promotions and their status |
| `consultar_cliente` | Retrieve details for the customer identified in the test |
| `consultar_pedidos` | Retrieve that customer's orders |
| `consultar_itens_pedido` | Retrieve products and quantities for an order within the customer's scope |
| `consultar_manual_loja` | Retrieve the complete manual in Markdown |

SQL queries are fixed and parameterized. The model does not receive a tool for executing arbitrary SQL. Session and message writes are controlled by the application, not by the agent.

One possible improvement is to introduce JOIN queries, views, or specialized database functions/procedures for frequent needs. This decision should be supported by measurements: fewer database and model round trips may help, but combining every search into one tool can also make its description and validation harder.

### Model and provider

I chose Google's Gemini, configured through `GEMINI_MODEL`, using `gemini-3.5-flash-lite` in this implementation. This decision was based on my previous experience with Google and OpenAI models, including building similar agents for data retrieval. Based on that experience, I selected a lightweight model to choose tools and produce responses from the sources, prioritizing response time and cost.

The goal is to support a store's customer service, and the current dataset is small. I considered that this task did not initially require a more complex model. Even for customers with several years of purchase history, the length of the relationship alone does not determine query complexity: the database can filter orders and return only the necessary data.

A supply or high-volume purchasing scenario could change this design, introducing more items, business rules, and relationships between orders. In that case, I would reassess the tools, history retrieval, and model choice against the new workload and business rules.

This choice does not imply guaranteed accuracy or superiority over other models. Results must be evaluated through actual conversations, particularly when applying policies or answering questions that require multiple queries. The provider's context capabilities were also considered, without treating the context window as a substitute for a retrieval strategy.

I used a free-tier API key for the prototype. Model access and quotas depend on the account and project. Questions requiring several rounds may reach a limit before a final response is generated.

In the current project configuration, `maximum_remote_calls` is **10**. This limits the SDK's automatic request loop; it is not the number of SQL tools or a per-minute or daily quota. A response may request more than one tool. I do not assume a fixed limit of 15 requests as a universal free-tier rule.

### PostgreSQL and data preparation

After defining the workflow, I mapped each CSV to a table and created the necessary relationships. I added two tables to persist conversations:

| Table | Contents |
|---|---|
| `public.categories` | Categories |
| `public.products` | Products, prices, stock levels, and specifications |
| `public.customers` | Customers |
| `public.orders` | Orders and tracking information |
| `public.order_items` | Products and quantities in each order |
| `public.promotions` | Promotions by product |
| `public.chat_session` | Session UUID, title, and timestamps |
| `public.chat_history` | Message UUID, session, role, text, and timestamps |

I preserved the provided IDs and data. Monetary values use `NUMERIC`, specifications use `JSONB`, and the active-promotion flag was converted to `BOOLEAN`. Empty optional fields were represented as `NULL`. Chat tables use automatically generated UUIDs and timestamps with time zone support.

Each category can have multiple products, each customer can have multiple orders, and each order can have multiple items. Products may appear in several order items and promotions. Each session contains multiple messages.

The catalog price is the product's current price. It is not assumed to be the historical purchase price; the recorded order total is retrieved from `orders.total_brl`.

Running PostgreSQL in Docker simplifies database setup. I kept Python outside the container and used uv/uv.lock to reproduce dependencies, maintaining a straightforward development and debugging workflow.

### History and continuity

History is retrieved before calling the model. In this version, the service call uses `limite=100`: up to **100 messages** are retrieved and ordered chronologically. The service accepts limits up to 1,000, but that is the maximum allowed by the method, not the number currently requested by the agent. The stored `assistant` role is converted to `model` when building Gemini's context.

The query method already accepts time-zone-aware start and end timestamps, with an inclusive start and an exclusive end. An improvement would be an automatic retrieval policy using windows of 1, 7, 30, 60, or 90 days, combined with message and token limits. A time window alone does not guarantee a small context.

Persisted history contains the conversation text. Intermediate events and tool results are not fully persisted as SDK state. The model may query a source again in later turns.

### Markdown manual without vector search

Because the provided manual is small, I chose to convert the PDF to Markdown with PyMuPDF4LLM, accounting for its tables and columns. The text stays in the `ChatGoogle` instance's memory, and the tool returns it when the agent needs to consult policies.

The PDF is not converted again for every message or tool call. A new instance performs a new conversion. Returning the manual to the model consumes tokens; keeping it in memory saves local processing, not API context usage.

For a larger document collection, I would evaluate chunking, embeddings, and vector retrieval with RAG. The goal would be to send relevant passages with references, assessing retrieval quality and overall cost before adding that complexity. Extracted tables must be checked for fidelity.

### Prompt design and refinement

The prompt is stored in a Markdown file and organized into tagged sections, such as persona, behavior, tool strategy, workflow, and rules. I used this structure to define responsibilities and make the prompt easier to read and maintain; tags do not guarantee that the model will always follow the instructions.

The process began with a baseline version. I used Gemini to discuss its interpretation of the instructions, identify ambiguities, and refine the context. That discussion supported development: behavior must be evaluated through responses and executed tools, not solely through the model's own explanation.

The instructions define the store's tone, selection between the database and manual, responses to missing data, refusal of out-of-scope topics, and treatment of tool outputs as data rather than new instructions.

### Interface and observability

I considered using Gradio but prioritized agent logic and source integration. The CLI supports conversations and observation of results without an additional visual interface.

Status output shows the tools actually executed, their outcomes, returned row counts, and local execution times. It also reports total turn time. The count adds rows from queries and may include the same product across different searches; it does not count distinct items or purchased products. For the manual, the record count is not applicable because the output is text.

Logs do not automatically display tool arguments or complete customer data. Execution metrics support diagnosis but do not establish response correctness on their own.

## Error Handling and Limitations

- Quota, availability, connection, timeout, and empty-response failures return a status to the caller.
- The automatic tool loop limit may stop a turn before a final response; simply making another model request does not resolve this.
- The HTTP timeout is 60 seconds per request, not per entire turn. Automatic HTTP retries are disabled in the implemented configuration.
- Only completed turns are stored as message pairs. A commit failure may leave confirmation uncertain; check history before resending.
- Real authentication, session-owner authorization, and pseudonymization are not implemented. The ID supplied through the CLI is exclusively for local testing.
- The CLI maintains one active conversation per execution; the database can store multiple sessions. There is no multiuser API, queue, or global concurrency/quota control.
- The message limit may truncate context. There is no summarization or automatic selection based on relevance and token budget yet.
- The complete manual may increase context usage, and table extraction may lose information.
- Hallucinations cannot be ruled out; responses must be checked against the sources.
- The agent retrieves information and provides guidance; it does not execute returns, refunds, or order changes. A textual offer to start those processes does not represent an implemented capability.

## Security Considerations Before Production

This is a demonstration prototype, not a production-ready customer service system. The controls below require implementation or further evaluation before handling real customer data and concurrent users.

### Customer identification and access control

The current behavior is conditional filtering: without `customer_id`, customer-specific tools return a message indicating that identification is missing; with `customer_id`, queries are filtered to that ID. Catalog and manual queries remain available without it.

The CLI accepts this ID manually. Its presence does not prove that the person using the application is that customer. This is not real authentication or a complete authorization mechanism. An empty query result only means that no record matched the filters; it does not establish whether an order does not exist or belongs to another customer.

Before production, customer identity must come from an authenticated backend context, with server-side authorization for every customer-specific operation. Sessions must also be linked to their owners, and access to a session must be checked before its history is retrieved. The model's instructions or selected arguments must not serve as the access-control boundary.

### Prompt injection and tool boundaries

Malicious instructions may appear directly in user messages or indirectly in retrieved content, such as the manual or database text. They may attempt to override the agent's scope, expose information, or induce inappropriate tool use.

The prompt instructs the model to treat retrieved content as data and ignore instructions embedded in it. This is a partial safeguard, not a sufficient security boundary. The prototype has not undergone a dedicated adversarial security evaluation, and resistance to prompt injection has not been established.

Further work should include tests for direct and indirect prompt injection, cross-customer data requests, and attempts to misuse tools. Backend-enforced access rules, validated tool arguments, restricted tool capabilities, and database permissions limited to the necessary operations must constrain what can actually be executed.

SQL queries are fixed and parameterized, which helps prevent SQL injection through query values. This addresses a different problem from prompt injection: parameterization does not prevent a model from requesting an otherwise valid query for an inappropriate purpose. Customer-data access must remain subject to backend checks.

### Personal data and operational safeguards

Before production, review which customer fields are exposed to tools and sent to the model provider, and establish retention and deletion policies for conversation history. Evaluate minimization, masking or pseudonymization, credential management, and protection of stored data and logs. Pseudonymization does not replace access control.

The application also needs broader failure and regression testing, request and quota controls, concurrent-session isolation, and monitoring. These are identified gaps and planned improvements, not controls claimed to be implemented or verified in the current prototype.

## Interaction Examples and Validation

The repository includes four conversations in `examples/`, with questions, answers, and tool logs:

| Example | Scenario |
|---|---|
| [Catalog](examples/catalog_01.md) | Guitars up to BRL 1,000, comparison, stock, and promotions |
| [Store policies](examples/store_policies_02.md) | Change-of-mind returns, conditions, and return requests |
| [Customer orders](examples/customers_order_03.md) | Order listing, status, tracking, items, and totals |
| [Out of scope](examples/out_of_scope_04.md) | Unrelated topic refusal, nonexistent product, and a request to invent a price |

The examples record observed agent behavior. Logs with `status=success` confirm workflow completion but do not certify every statement's accuracy. Data and policies must be checked against the sources.

With the assistant\'s support, the customer 3 order scenario was checked against the CSV files: orders 1 and 19; order 1 contains one unit of product 93, Martin D-28 Dreadnought Natural, with a recorded total of BRL 11,499.00.

The catalog conversation also reveals an improvement opportunity: a follow-up question triggered multiple searches, some without results. This highlights the need to assess tool efficiency and context use as well as the final response.

This version does not include an automated test suite. The files in `examples/` document manual interactions. As a future improvement, I intend to add regression tests for filters, history, and failures, together with evaluations against the source data.

## Improvements with More Time

1. Implement authentication and authorization, separating anonymous catalog access from identified access to customer and order data, and linking sessions to their owners.
2. Reduce personal data exposure through minimization, masking, or pseudonymization as needed. Access control remains necessary.
3. Define a retrieval policy based on time window, tokens, and relevance, with pagination and potential history summarization.
4. Build a multiuser API with session isolation, serialized turns within each session, quota controls, and concurrency handling.
5. Measure recurring queries to decide when to consolidate tools, JOINs, views, or database routines.
6. Evaluate RAG and vector indexing when document volume justifies them, with references to retrieved passages.
7. Add a Gradio interface for navigating conversations and presenting responses more clearly.
8. Expand evaluations of policy application, scope, instruction injection, and grounding, while improving execution metrics.

## Use of AI Assistants and My Contribution

All ChatGPT use throughout this project took place in **ChatGPT Work**. Its contribution included generating complete files, not only suggesting or reviewing small code snippets.

ChatGPT Work helped generate and revise:

- Python files for the Gemini integration, database service, and terminal interaction.
- SQL files for table definitions, relationships, and the initial data load.
- The Docker Compose configuration and example environment configuration.
- Tool logging and error-handling code.
- Test scenarios and simulated tests used during development; the submitted version does not include an automated test suite.
- This README, its workflow diagram, and its English translation.

I described the intended workflow and the reasons behind my technical choices, defined the directory structure myself, and organized the project files. I used my previous experience with Google and OpenAI models and similar retrieval agents to guide the model choice and solution design. I ran the application on Windows 11 with uv and VS Code, reported errors encountered during execution, and used the assistant's suggestions to make adjustments.

For prompt development, I also used **Gemini** to discuss how it interpreted the tagged sections, identify ambiguities, and support refinements. The prompt strategy and its evaluation were informed by those discussions and the observed conversations.

I developed the implementation with substantial assistance from ChatGPT Work and tested it manually on Windows 11 using uv and VS Code. The conversations in examples/ document these executions. With the assistant’s support, I also checked the order scenario against the supplied CSV data. Known limitations are documented above.
