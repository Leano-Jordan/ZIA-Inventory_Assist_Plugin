-- PostgreSQL baseline for ZIA.
-- Fresh database baseline: all application and Shopify session tables are created here.

CREATE TABLE "Session" (
  "id" TEXT NOT NULL,
  "shop" TEXT NOT NULL,
  "state" TEXT NOT NULL,
  "isOnline" BOOLEAN NOT NULL DEFAULT false,
  "scope" TEXT,
  "expires" TIMESTAMP(3),
  "accessToken" TEXT NOT NULL,
  "userId" BIGINT,
  "firstName" TEXT,
  "lastName" TEXT,
  "email" TEXT,
  "accountOwner" BOOLEAN NOT NULL DEFAULT false,
  "locale" TEXT,
  "collaborator" BOOLEAN DEFAULT false,
  "emailVerified" BOOLEAN DEFAULT false,
  "refreshToken" TEXT,
  "refreshTokenExpires" TIMESTAMP(3),
  CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "Session_shop_idx" ON "Session"("shop");

CREATE TABLE "Supplier" (
  "id" TEXT NOT NULL,
  "shop" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "email" TEXT,
  "phone" TEXT,
  "notes" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Supplier_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "Supplier_shop_name_key" ON "Supplier"("shop", "name");
CREATE INDEX "Supplier_shop_idx" ON "Supplier"("shop");

CREATE TABLE "SupplierItem" (
  "id" TEXT NOT NULL,
  "supplierId" TEXT NOT NULL,
  "shop" TEXT NOT NULL,
  "variantGid" TEXT NOT NULL,
  "inventoryItemGid" TEXT,
  "sku" TEXT,
  "unitCost" DOUBLE PRECISION,
  "leadTimeDays" INTEGER,
  "reorderPoint" INTEGER,
  "reorderQuantity" INTEGER,
  "active" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "SupplierItem_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "SupplierItem_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier"("id") ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX "SupplierItem_supplierId_variantGid_key" ON "SupplierItem"("supplierId", "variantGid");
CREATE INDEX "SupplierItem_shop_variantGid_idx" ON "SupplierItem"("shop", "variantGid");

CREATE TABLE "ReorderRule" (
  "id" TEXT NOT NULL,
  "shop" TEXT NOT NULL,
  "variantGid" TEXT NOT NULL,
  "locationGid" TEXT NOT NULL,
  "reorderPoint" INTEGER NOT NULL DEFAULT 0,
  "targetStock" INTEGER NOT NULL DEFAULT 0,
  "preferredSupplierId" TEXT,
  "active" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "ReorderRule_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "ReorderRule_preferredSupplierId_fkey" FOREIGN KEY ("preferredSupplierId") REFERENCES "Supplier"("id") ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE UNIQUE INDEX "ReorderRule_shop_variantGid_locationGid_key" ON "ReorderRule"("shop", "variantGid", "locationGid");
CREATE INDEX "ReorderRule_shop_active_idx" ON "ReorderRule"("shop", "active");

CREATE TABLE "PurchaseOrder" (
  "id" TEXT NOT NULL,
  "shop" TEXT NOT NULL,
  "number" TEXT NOT NULL,
  "supplierId" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "orderedAt" TIMESTAMP(3),
  "expectedAt" TIMESTAMP(3),
  "locationGid" TEXT,
  "locationName" TEXT,
  "receivedAt" TIMESTAMP(3),
  "notes" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "PurchaseOrder_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "PurchaseOrder_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE UNIQUE INDEX "PurchaseOrder_shop_number_key" ON "PurchaseOrder"("shop", "number");
CREATE INDEX "PurchaseOrder_shop_status_idx" ON "PurchaseOrder"("shop", "status");

CREATE TABLE "PurchaseOrderLine" (
  "id" TEXT NOT NULL,
  "purchaseOrderId" TEXT NOT NULL,
  "variantGid" TEXT NOT NULL,
  "inventoryItemGid" TEXT,
  "sku" TEXT,
  "title" TEXT NOT NULL,
  "quantityOrdered" INTEGER NOT NULL,
  "quantityReceived" INTEGER NOT NULL DEFAULT 0,
  "unitCost" DOUBLE PRECISION,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "PurchaseOrderLine_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "PurchaseOrderLine_purchaseOrderId_fkey" FOREIGN KEY ("purchaseOrderId") REFERENCES "PurchaseOrder"("id") ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX "PurchaseOrderLine_purchaseOrderId_idx" ON "PurchaseOrderLine"("purchaseOrderId");
CREATE INDEX "PurchaseOrderLine_variantGid_idx" ON "PurchaseOrderLine"("variantGid");

CREATE TABLE "InventoryAudit" (
  "id" TEXT NOT NULL,
  "shop" TEXT NOT NULL,
  "variantGid" TEXT NOT NULL,
  "inventoryItemGid" TEXT,
  "locationGid" TEXT,
  "locationName" TEXT,
  "quantityBefore" INTEGER,
  "quantityAfter" INTEGER,
  "change" INTEGER,
  "reason" TEXT NOT NULL,
  "source" TEXT NOT NULL,
  "syncStatus" TEXT,
  "syncError" TEXT,
  "syncedAt" TIMESTAMP(3),
  "actor" TEXT,
  "metadata" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "InventoryAudit_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "InventoryAudit_shop_variantGid_createdAt_idx" ON "InventoryAudit"("shop", "variantGid", "createdAt");
CREATE INDEX "InventoryAudit_shop_locationGid_createdAt_idx" ON "InventoryAudit"("shop", "locationGid", "createdAt");
CREATE INDEX "InventoryAudit_shop_syncStatus_createdAt_idx" ON "InventoryAudit"("shop", "syncStatus", "createdAt");

CREATE TABLE "SyncState" (
  "id" TEXT NOT NULL,
  "shop" TEXT NOT NULL,
  "resource" TEXT NOT NULL,
  "cursor" TEXT,
  "lastSyncedAt" TIMESTAMP(3),
  "lastSuccessfulAt" TIMESTAMP(3),
  "lastError" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "SyncState_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "SyncState_shop_resource_key" ON "SyncState"("shop", "resource");
CREATE INDEX "SyncState_shop_idx" ON "SyncState"("shop");
