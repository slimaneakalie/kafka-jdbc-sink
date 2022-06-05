DROP TABLE IF EXISTS "predictions_table";
DROP SEQUENCE IF EXISTS predictions_table_id_seq;
CREATE SEQUENCE predictions_table_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."predictions_table" (
    "id" bigint DEFAULT nextval('predictions_table_id_seq') NOT NULL,
    "category" text NOT NULL,
    "text" text NOT NULL,
    "created_at" timestamp NOT NULL,
    CONSTRAINT "predictions_table_pkey" PRIMARY KEY ("id")
) WITH (oids = false);
