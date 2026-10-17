import type { LoaderFunctionArgs } from "react-router";
import { redirect, Form, useLoaderData } from "react-router";
import { login } from "../../shopify.server";
import styles from "./styles.module.css";

export const loader = async ({ request }: LoaderFunctionArgs) => {
  const url = new URL(request.url);
  if (url.searchParams.get("shop")) {
    throw redirect(`/app?${url.searchParams.toString()}`);
  }
  return { showForm: Boolean(login) };
};

export default function App() {
  const { showForm } = useLoaderData<typeof loader>();
  return (
    <main className={styles.index}>
      <section className={styles.content}>
        <div className={styles.brand}><span className={styles.mark}>Z</span><span>ZIA <small>INVENTORY CONTROL</small></span></div>
        <p className={styles.eyebrow}>SHOPIFY INVENTORY INTELLIGENCE</p>
        <h1 className={styles.heading}>Know what you have.<br/><span>Plan what comes next.</span></h1>
        <p className={styles.text}>A clearer view of stock, replenishment, suppliers, and purchase orders — built around your Shopify inventory.</p>
        {showForm && <Form className={styles.form} method="post" action="/auth/login">
          <label className={styles.label}><span>Shop domain</span><input className={styles.input} type="text" name="shop" placeholder="your-store.myshopify.com" autoComplete="url" required /></label>
          <button className={styles.button} type="submit">Open your workspace <span aria-hidden="true">→</span></button>
        </Form>}
        <div className={styles.features}>
          <article><span className={styles.featureIcon}>01</span><strong>Stock visibility</strong><p>See low-stock and out-of-stock variants.</p></article>
          <article><span className={styles.featureIcon}>02</span><strong>Smarter reordering</strong><p>Organise reorder rules and suppliers.</p></article>
          <article><span className={styles.featureIcon}>03</span><strong>Purchasing control</strong><p>Track orders and receiving in one place.</p></article>
        </div>
        <footer>Designed for Shopify merchants <span>•</span> ZIA Preview</footer>
      </section>
    </main>
  );
}
