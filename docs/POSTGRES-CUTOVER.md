# ZIA PostgreSQL persistence cutover

## What changed

The application Prisma datasource now uses PostgreSQL through `DATABASE_URL`.
The migration directory contains a clean PostgreSQL baseline for all current models,
including Shopify sessions, suppliers, purchase orders, inventory audit and sync state.
`InventoryAudit.syncedAt` is now represented in the Prisma schema as well as the database.

The old SQLite migration scripts were replaced on this branch because they contain
SQLite-specific SQL and cannot be deployed to PostgreSQL. The `main` branch and its
SQLite history are untouched.

## Preview database

A temporary Render PostgreSQL database was provisioned for validation:

- Name: `zia-postgres-preview`
- Region: Singapore
- Plan: Free
- Expires: 2026-12-03
- Database ID: `dpg-dbl0tlk9v7es73fj84lg-a`

This is a short-lived test database, not a production database. It has no durable
retention guarantee and must not be used for customer production data.

## Required Render configuration

Set the web service environment variable `DATABASE_URL` to the database's **Internal
Database URL** from the Render database dashboard. Do not commit the URL or credentials.
The Render blueprint declares this variable as a secret (`sync: false`).

The application service and database should be in the same Render region for internal
network access. The existing web service currently runs in its own configured region;
verify the actual service region before using an internal URL. If regions differ, move
one service or use the external URL only if required.

## Cutover procedure

1. Confirm the preview database is `available`.
2. Set `DATABASE_URL` on a separate preview service or on the existing service only
   after confirming the current preview data is disposable.
3. Deploy this branch to the preview service.
4. Confirm `prisma migrate deploy` completes successfully in startup logs.
5. Confirm the `Session`, `Supplier`, `SupplierItem`, `ReorderRule`,
   `PurchaseOrder`, `PurchaseOrderLine`, `InventoryAudit`, and `SyncState`
   tables exist.
6. Install the app on a development Shopify store and verify OAuth session persistence.
7. Restart/redeploy the preview service and verify the session and application rows persist.
8. Only after these checks should the change be considered for merge and production.

## Existing SQLite data

This baseline creates an empty PostgreSQL schema. It does not copy SQLite records.
Do not point an existing production installation at this branch until any required
supplier, purchase-order and audit data has been exported and imported. Shopify product
and inventory data can be re-read from Shopify; locally created purchasing records
cannot be reconstructed automatically.

## Rollback

Rollback means redeploying the existing `main` branch with its SQLite configuration.
Do not attempt to run SQLite migration SQL against PostgreSQL or PostgreSQL baseline SQL
against SQLite.
