// Verificación de firma de los webhooks de Tiendanube.
// Firman el body crudo con HMAC-SHA256 usando el Client Secret de la app,
// codificado en hexadecimal, en el header "x-linkedstore-hmac-sha256".

export async function verifyTiendanubeHmac(
  rawBody: string,
  secret: string,
  signatureHex: string
): Promise<boolean> {
  try {
    const enc = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      enc.encode(secret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const sigBuf = await crypto.subtle.sign("HMAC", key, enc.encode(rawBody));
    const computed = Array.from(new Uint8Array(sigBuf))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");
    return computed.toLowerCase() === signatureHex.toLowerCase();
  } catch {
    return false;
  }
}

// Chequeo estándar a usar al principio de cada webhook: devuelve el body
// crudo si la firma es válida, o null si hay que rechazar la request.
export async function requireValidSignature(req: Request): Promise<string | null> {
  const rawBody = await req.text();
  const secret = Deno.env.get("TIENDANUBE_CLIENT_SECRET");
  const sigHeader = req.headers.get("x-linkedstore-hmac-sha256");
  if (!secret || !sigHeader) return null;
  const valid = await verifyTiendanubeHmac(rawBody, secret, sigHeader);
  return valid ? rawBody : null;
}
