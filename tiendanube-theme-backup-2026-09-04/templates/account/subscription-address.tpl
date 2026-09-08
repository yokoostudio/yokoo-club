{% embed "snipplets/page-header.tpl" %}
    {% block page_header_text %}
        {{- 'our_components.customer_subscriptions.address_page_title' | tt -}}
    {% endblock page_header_text %}
{% endembed %}

<section class="account-page mb-4">
    <div class="container" data-store="account-subscription-address-{{ subscription.id }}">
        <div class="row justify-content-center">
            <div class="col-md-6">
                {{ component('subscriptions/subscription-address-form', {
                    subscription: subscription,
                    address_classes: {
                        notice: 'alert alert-info mt-0 mb-3 font-small',
                        field_error: 'notification-danger notification-left',
                        fields: 'row',
                        field_full: 'form-group col-12',
                        field_left: 'form-group col-8',
                        field_right: 'form-group col-4',
                        label: 'form-label font-small',
                        input: 'form-control font-small',
                        actions: 'mt-3',
                        submit: 'btn btn-primary btn-block',
                    },
                }) }}
            </div>
        </div>
    </div>
</section>
