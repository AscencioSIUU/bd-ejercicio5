CREATE OR REPLACE FUNCTION substract_stock_after_sale()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO inventory_logs (quantity, product_id)
	VALUES (-NEW.quantity, NEW.product_id)
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_sale_details
AFTER INSERT ON sale_details
FOR EACH ROW
EXECUTE FUNCTION substract_stock_after_sale();

CREATE OR REPLACE FUNCTION update_stock_from_inventory_logs()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE product
	SET current_stock = current_stock + NEW.quantity
	WHERE id = NEW.product_id
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_inventory_logs
AFTER INSERT ON inventory_logs
FOR EACH ROW
EXECUTE FUNCTION update_stock_from_inventory_logs();

CREATE OR REPLACE FUNCTION check_stock()
RETURNS TRIGGER AS $$
BEGIN
	IF(SELECT current_stock FROM product WHERE id = NEW.product_id) - NEW.quantity < 0 THEN
	RAISE EXCEPTION 'No hay suficiente stock para este producto';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_sale_details
BEFORE INSERT ON sale_details
FOR EACH ROW 
EXECUTE FUNCTION check_stock();

CREATE OR REPLACE FUNCTION check_pet_state()
RETURNS TRIGGER AS $$
BEGIN
	IF NOT (SELECT isAlive FROM pet WHERE id = NEW.pet_id) THEN
	RAISE EXCEPTION 'No se puede crear una cita para una mascota fallecida.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_appointment
BEFORE INSERT ON appointment
FOR EACH ROW
EXECUTE FUNCTION check_pet_state();

CREATE OR REPLACE FUNCTION prevent_inventory_and_product_truncate()
RETURNS event_trigger AS $$
DECLARE obj record;
BEGIN
	FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
	LOOP
		IF obj.object_type = 'table' AND obj.object_identity IN ('public.inventory_logs', 'public.product') THEN
		RAISE EXCEPTION 'No es posible truncar inventory_logs o product';
		END IF;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER before_truncate()
ON sql_drop
WHEN TAG IN ('TRUNCATE')
EXECUTE FUNCTION prevent_inventory_and_product_truncate();

CREATE OR REPLACE FUNCTION log_truncate()
RETURNS event_trigger AS $$
DECLARE r record;
BEGIN
	FOR r in SELECT * FROM pg_event_trigger_dropped_objects()
	LOOP
		INSERT INTO truncate_log(table_name)
		VALUES (r.object_identity::text);
	END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER after_truncate
ON sql_drop
WHEN TAG IN ('TRUNCATE')
EXECUTE FUNCTION log_truncate();






