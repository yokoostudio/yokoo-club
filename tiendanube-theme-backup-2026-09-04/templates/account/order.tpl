{% embed "snipplets/page-header.tpl" %}
    {% block page_header_text %}
        {%- set page_title = is_subscription ? subscription.id : ('Orden #{1}' | translate(order.number)) -%}
        {{- page_title -}}
    {% endblock page_header_text %}
{% endembed %}

{% set detail_data_store = is_subscription ? 'account-subscription-detail-' ~ subscription.id : 'account-order-detail-' ~ order.id %}
<section class="account-page mt-3 mb-4">
    <div class="container" data-store="{{ detail_data_store }}">
        {% if is_subscription %}
            {{ component('subscriptions/subscription-detail', {
                subscription: subscription,
                last_order: last_order,
                last_order_items: last_order_items,
                enable_subscription_cancel: true,
                select_svg_id: 'chevron',
                close_icon_id: 'times',
                subscription_classes: {
                    container: 'row',
                    alert: 'col-12 alert mt-0 mb-3',
                    alert_success: 'alert-success',
                    alert_error: 'alert-danger',
                    info_section: 'col-md-4 mb-3',
                    items_section: 'col-md-8',
                    info: {
                        info_header: 'row align-items-center mt-3 mb-2',
                        info_title: 'd-inline-block m-0 col',
                        info_action: 'btn-link font-small col-auto',
                        info_item: 'font-small mb-2',
                        info_item_value: 'font-weight-bold',
                        address_container: 'font-small mb-2',
                        address_line: 'd-block',
                    },
                    skip_modal: {
                        open_modal_button: 'btn-link font-small col-auto',
                        message: 'mb-2',
                        actions: 'd-flex align-items-center justify-content-end mt-3',
                        back_button: 'btn btn-link mr-3',
                        confirm_button: 'btn btn-primary',
                        modal: 'modal-centered-small modal-centered transition-soft',
                        modal_title: 'flex-grow-1 text-center',
                        header: 'd-flex align-items-center px-3',
                    },
                    cancel_modal: {
                        open_modal_button: 'btn-link font-small col-auto',
                        message: 'mb-2',
                        field: 'form-group',
                        label: 'form-label font-small',
                        select: 'form-control font-small',
                        select_icon: 'form-select-icon',
                        select_svg: 'icon-inline icon-w-14 icon-rotate-90',
                        actions: 'd-flex align-items-center justify-content-end mt-3',
                        back_button: 'btn btn-link mr-3',
                        confirm_button: 'btn btn-primary',
                        modal: 'modal-centered-small modal-centered transition-soft',
                        close_icon: 'icon-inline svg-icon-text',
                        overlay: 'modal-backdrop-zindex-top',
                        modal_title: 'flex-grow-1 text-center',
                        header: 'd-flex align-items-center px-3',
                    },
                    items: {
                        header: 'mb-1 d-none d-md-block',
                        header_content: 'row',
                        header_product_label: 'col-6 mb-2 font-small',
                        header_label: 'col-2 text-center mb-2 font-small',
                        items_container: 'order-detail card mb-3',
                        item: 'order-item p-3 font-small',
                        item_content: 'row align-items-center',
                        product: 'col-7 col-md-6',
                        product_content: 'row align-items-center',
                        image_container: 'col-4 col-md-2 pr-0',
                        image_frame: 'card-img-square-container',
                        image: 'd-block card-img-square',
                        name: 'col-8 col-md-9',
                        name_quantity: 'd-inline-block d-md-none text-center',
                        price: 'col-2 d-none d-md-flex align-self-stretch justify-content-center',
                        quantity: 'col-2 d-none d-md-flex align-self-stretch justify-content-center',
                        subtotal: 'col-5 col-md-2 d-flex px-3 align-self-stretch justify-content-end justify-content-center-md',
                        value: 'd-flex align-self-center',
                    }
                }
            }) }}
        {% else %}
        {% if cancel_error == 'in_review' %}
            <div class="alert alert-info mb-3">
                <span class="font-weight-bold">{{ 'Tu solicitud de cancelación está siendo revisada' | translate }}</span>
                {% if store.cancel_review_time %}
                    {% if store.cancel_review_time_unit == 'hours' %}
                        <p class="mt-1 mb-0">{{ 'La tienda tiene hasta {1} hs para revisarla. Te avisaremos el resultado por email a {2}.' | translate(store.cancel_review_time, customer.email) }}</p>
                    {% else %}
                        <p class="mt-1 mb-0">{{ 'La tienda tiene hasta {1} días para revisarla. Te avisaremos el resultado por email a {2}.' | translate(store.cancel_review_time, customer.email) }}</p>
                    {% endif %}
                {% else %}
                    <p class="mt-1 mb-0">{{ 'Te avisaremos el resultado por email a {1}.' | translate(customer.email) }}</p>
                {% endif %}
            </div>
        {% elseif cancel_success and order.status != 'cancelled' %}
            <div class="alert alert-info mb-3">
                <span class="font-weight-bold">{{ 'Tu solicitud de cancelación está siendo revisada' | translate }}</span>
                <p class="mt-1 mb-0">{{ 'Te avisaremos el resultado por email a {1}.' | translate(customer.email) }}</p>
            </div>
        {% endif %}
    	<div class="row">
            <div class="col-md-4 mb-3">
                {% if log_entry %}
                    <h4>{{ 'Estado actual del envío' | translate }}:</h4>{{ log_entry }}
                {% endif %}
                <div class="font-small mb-2">
                    {{'Fecha' | translate}}: <strong>{{ order.date | i18n_date('%d/%m/%Y') }}</strong> 
                </div>
                <div class="font-small mb-2">
                    {{'Estado' | translate}}: <strong>{{ (order.status == 'open'? 'Abierta' : (order.status == 'closed'? 'Cerrada' : (order.status == 'cancellation_pending'? 'Cancelación pendiente' : 'Cancelada'))) | translate }}</strong>
                </div>
                <div class="font-small mb-2">
                    {{'Pago' | translate}}: <strong>{{ (order.payment_status == 'pending'? 'Pendiente' : (order.payment_status == 'authorized'? 'Autorizado' : (order.payment_status == 'paid'? 'Pagado' : (order.payment_status == 'voided'? 'Cancelado' : (order.payment_status == 'refunded'? 'Reintegrado' : 'Abandonado'))))) | translate }} </strong>
                </div>
                <div class="font-small mb-2">
                    {{'Medio de pago' | translate}}: <strong>{{ order.payment_name }}</strong>
                </div>

                {% if order.address %}
                    <div class="font-small mb-2">
                        {{'Envío' | translate}}: <strong>{{ (order.shipping_status == 'fulfilled'? 'Enviado' : (order.shipping_status == 'delivered'? 'Entregado' : 'No enviado')) | translate }}</strong>
                    </div>
                    <div class="font-small mt-3 mb-2">
                        <strong>{{ 'Dirección de envío' | translate }}:</strong>
                        <span class="d-block d-block mt-1">
                            {{ order.address | format_address }}
                        </span>
                    </div>
                {% endif %}
                {% if order_subscription %}
                    {{ component('subscriptions/subscription-summary', {
                        order_subscription: order_subscription,
                        subscription_classes: {
                            info_title: 'font-small font-weight-bold mt-3 mb-2',
                            info_item: 'font-small mb-2',
                            info_item_value: 'font-weight-bold',
                        },
                    }) }}
                {% endif %}
                {{ component('cancel-order-modal', {
                    select_svg_id: 'chevron',
                    classes: {
                        message: 'mb-2',
                        warning: 'mb-3',
                        label: 'form-label',
                        actions: 'd-flex align-items-center justify-content-end mt-3',
                        back_button: 'btn btn-link mr-2 mt-3',
                        confirm_button: 'btn btn-primary',
                        modal: 'modal-centered-small modal-centered transition-soft',
                        open_modal_button: 'btn btn-secondary d-block mt-2',
                        select_svg: 'icon-inline icon-w-14 icon-rotate-90',
                        modal_title: 'flex-grow-1 text-center',
                        header: 'd-flex align-items-center px-3'
                    }
                }) }}
            </div>
            <div class="col-md-8">
                <div class="mb-1 d-none d-md-block">
                    <div class="row">
                        <div class="col-6 mb-2 font-small">
                            {{ 'Producto' | translate }}
                        </div>
                        <div class="col-2 text-center mb-2 font-small">
                            {{ 'Precio' | translate }}
                        </div>
                        <div class="col-2 text-center mb-2 font-small">
                            {{ 'Cantidad' | translate }}
                        </div>
                        <div class="col-2 text-center mb-2 font-small">
                            {{ 'Total' | translate }}
                        </div>
                    </div>
                </div>
                <div class="order-detail card mb-3">
                    {% for item in order.items %}
                        <div class="order-item p-3 font-small">
                            <div class="row align-items-center">
                                <div class="col-7 col-md-6">
                                    <div class="row align-items-center">
                                        <div class="col-4 col-md-2 pr-0">
                                            <div class="card-img-square-container">
                                                {{ item.featured_image | product_image_url("small") | img_tag(item.featured_image.alt, {class: 'd-block card-img-square'}) }} 
                                            </div>
                                        </div>
                                        <div class="col-8 col-md-9">
                                            {{ item.name }} <span class="d-inline-block d-md-none text-center">x{{ item.quantity }}</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-2 d-none d-md-flex align-self-stretch justify-content-center">
                                    <span class="d-flex align-self-center">
                                        {{ item.unit_price | money }}
                                    </span>
                                </div>
                                <div class="col-2 d-none d-md-flex align-self-stretch justify-content-center">
                                    <span class="d-flex align-self-center">
                                        {{ item.quantity }}
                                    </span>
                                </div>
                                <div class="col-5 col-md-2 d-flex px-3 align-self-stretch justify-content-end justify-content-center-md">
                                    <span class="d-flex align-self-center">
                                        {{ item.subtotal | money }}
                                    </span>
                                </div>
                            </div>
                        </div>
                    {% endfor %}
                </div>
                {% if order.show_shipping_price %}
                    <div class="mb-2 text-right">
                        <strong class="font-small">{{ 'Costo de envío ({1})' | translate(order.shipping_name) }}:</strong>
                        {% if order.shipping == 0  %}
                            {{ 'Gratis' | translate }}
                        {% else %}
                            {{ order.shipping | money_long }}
                        {% endif %}
                    </div>
                {% else %}
                    <div class="mb-2 text-right">
                        <strong class="font-small">{{ 'Costo de envío ({1})' | translate(order.shipping_name) }}:</strong>
                        {{ 'A convenir' | translate }}
                    </div>
                {% endif %}
                {% if order.discount %}
                    <div class="mb-2 text-right">
                       <strong class="font-small">{{ 'Descuento ({1})' | translate(order.coupon) }}:</strong>
                        - {{ order.discount | money }}
                    </div>
                {% endif %}
                {% if order.shipping or order.discount %}
                    <div class="mb-2 text-right">
                        <strong class="font-small">{{ 'Subtotal' | translate }}:</strong>
                        {{ order.subtotal | money }}
                    </div>
                {% endif %}  
                <h3 class="font-huge mb-3 text-right">{{ 'Total' | translate }}: {{ order.total | money }}</h3>
                {% if order.pending %}
                    <div class="text-right">
                        <a class="btn btn-primary btn-big d-inline-block col col-md-4" href="{{ order.checkout_url | add_param('ref', 'orders_details') }}" target="_blank">{{ 'Realizar el pago' | translate }}</a>
                    </div>
                {% endif %}
            </div>
    	</div>
        {% endif %}
    </div>
</section>