// adapted from:
// https://github.com/jedisct1/siphash-js/blob/master/lib/siphash13.ts

// -- constants --
const key = new Uint32Array([
  0x59a095a3,
  0x6e56695e,
  0x1f8cc7cb,
  0xe507f690,
])

// -- types --
interface IU64 {
  l: number;
  h: number;
}

// -- impls --
export const SipHash = {
  hex(m: Uint8Array | string): string {
    const r = hash(key, m);

    return (
      ("0000000" + r.h.toString(16)).substr(-8) +
      ("0000000" + r.l.toString(16)).substr(-8)
    );
  }
}

// -- impls/helpers
function add(a: IU64, b: IU64) {
  const rl = a.l + b.l,
    a2 = {
      h: (a.h + b.h + ((rl / 2) >>> 31)) >>> 0,
      l: rl >>> 0,
    };
  a.h = a2.h;
  a.l = a2.l;
}

function xor(a: IU64, b: IU64) {
  a.h ^= b.h;
  a.h >>>= 0;
  a.l ^= b.l;
  a.l >>>= 0;
}

function rotl(a: IU64, n: number) {
  const a2 = {
    h: (a.h << n) | (a.l >>> (32 - n)),
    l: (a.l << n) | (a.h >>> (32 - n)),
  };
  a.h = a2.h;
  a.l = a2.l;
}

function rotl32(a: IU64) {
  const al = a.l;
  a.l = a.h;
  a.h = al;
}

function compress(v0: IU64, v1: IU64, v2: IU64, v3: IU64) {
  add(v0, v1);
  add(v2, v3);
  rotl(v1, 13);
  rotl(v3, 16);
  xor(v1, v0);
  xor(v3, v2);
  rotl32(v0);
  add(v2, v1);
  add(v0, v3);
  rotl(v1, 17);
  rotl(v3, 21);
  xor(v1, v2);
  xor(v3, v0);
  rotl32(v2);
}

function getInt(a: Uint8Array, offset: number) {
  return (
    (a[offset + 3] << 24) |
    (a[offset + 2] << 16) |
    (a[offset + 1] << 8) |
    a[offset]
  );
}

function hash(key: Uint32Array, m: Uint8Array | string): IU64 {
  if (typeof m === "string") {
    m = stringToU8(m);
  }
  const k0 = {
    h: key[1] >>> 0,
    l: key[0] >>> 0,
  },
    k1 = {
      h: key[3] >>> 0,
      l: key[2] >>> 0,
    },
    v0 = {
      h: k0.h,
      l: k0.l,
    },
    v2 = k0,
    v1 = {
      h: k1.h,
      l: k1.l,
    },
    v3 = k1,
    ml = m.length,
    ml7 = ml - 7,
    buf = new Uint8Array(new ArrayBuffer(8));

  xor(v0, {
    h: 0x736f6d65,
    l: 0x70736575,
  });
  xor(v1, {
    h: 0x646f7261,
    l: 0x6e646f6d,
  });
  xor(v2, {
    h: 0x6c796765,
    l: 0x6e657261,
  });
  xor(v3, {
    h: 0x74656462,
    l: 0x79746573,
  });
  let mp = 0;
  while (mp < ml7) {
    const mi = {
      h: getInt(m, mp + 4),
      l: getInt(m, mp),
    };
    xor(v3, mi);
    compress(v0, v1, v2, v3);
    xor(v0, mi);
    mp += 8;
  }
  buf[7] = ml;
  let ic = 0;
  while (mp < ml) {
    buf[ic++] = m[mp++];
  }
  while (ic < 7) {
    buf[ic++] = 0;
  }
  const mil = {
    h: (buf[7] << 24) | (buf[6] << 16) | (buf[5] << 8) | buf[4],
    l: (buf[3] << 24) | (buf[2] << 16) | (buf[1] << 8) | buf[0],
  };
  xor(v3, mil);
  compress(v0, v1, v2, v3);
  xor(v0, mil);
  xor(v2, {
    h: 0,
    l: 0xff,
  });
  compress(v0, v1, v2, v3);
  compress(v0, v1, v2, v3);
  compress(v0, v1, v2, v3);

  const h = v0;
  xor(h, v1);
  xor(h, v2);
  xor(h, v3);

  return h;
}

function stringToU8(str: string): Uint8Array {
  if (typeof TextEncoder === "function") {
    return new TextEncoder().encode(str);
  }
  str = unescape(encodeURIComponent(str));
  const bytes = new Uint8Array(str.length);
  for (let i = 0, j = str.length; i < j; i++) {
    bytes[i] = str.charCodeAt(i);
  }
  return bytes;
}
