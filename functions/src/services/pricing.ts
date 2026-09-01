/**
 * Authoritative Blaze pricing constants (USD) for Google Cloud / Firebase (us-central1 list prices).
 */
export const FIREBASE_PRICING = {
  readPer100k: 0.06,
  writePer100k: 0.18,
  deletePer100k: 0.02,
  firestoreStoredGiBMonth: 0.18,
  storageStoredGiBMonth: 0.026,
  egressPerGiB: 0.12,
  functionsPerMillion: 0.40,
  hostingPerMonth: 0.0,
};

const BYTES_PER_GIB = 1024 * 1024 * 1024;

export interface CostBreakdown {
  firestoreCost: number;
  storageCost: number;
  functionsCost: number;
  hostingCost: number;
  totalCostUsd: number;
}

/**
 * Calculates server-side estimated cost for a given daily metric set.
 */
export function calculateDailyCost(metrics: {
  reads: number;
  writes: number;
  deletes: number;
  firestoreStoredBytes: number;
  storageStoredBytes: number;
  egressBytes: number;
  functionInvocations: number;
}): CostBreakdown {
  const p = FIREBASE_PRICING;

  // Stored data is monthly, so single day carries 1/30th
  const firestoreStorageDaily = (metrics.firestoreStoredBytes / BYTES_PER_GIB * p.firestoreStoredGiBMonth) / 30;
  const cloudStorageDaily = (metrics.storageStoredBytes / BYTES_PER_GIB * p.storageStoredGiBMonth) / 30;
  const egressCost = (metrics.egressBytes / BYTES_PER_GIB) * p.egressPerGiB;

  const firestoreCost =
    (metrics.reads / 100000) * p.readPer100k +
    (metrics.writes / 100000) * p.writePer100k +
    (metrics.deletes / 100000) * p.deletePer100k +
    firestoreStorageDaily;

  const storageCost = cloudStorageDaily + egressCost;

  const functionsCost =
    (metrics.functionInvocations / 1000000) * p.functionsPerMillion;

  const hostingCost = p.hostingPerMonth / 30;

  const totalCostUsd = firestoreCost + storageCost + functionsCost + hostingCost;

  return {
    firestoreCost: Number(firestoreCost.toFixed(4)),
    storageCost: Number(storageCost.toFixed(4)),
    functionsCost: Number(functionsCost.toFixed(4)),
    hostingCost: Number(hostingCost.toFixed(4)),
    totalCostUsd: Number(totalCostUsd.toFixed(4)),
  };
}
