{% set label_accent_classes = 'label label-accent mb-2' %}
{% set label_default_classes = 'label label-default mb-2 ' ~ (product_detail ? 'label-big') %}

{{ component(
  'labels', {
    defer_stock_label_text: true,
    prioritize_promotion_over_offer: true,
    promotion_nxm_long_wording: false,
    promotion_quantity_long_wording: true,
    labels_classes: {
      group: 'js-labels-floating-group labels',
      promotion: label_accent_classes,
      promotion_primary_text: 'd-block',
      offer: 'js-offer-label ' ~ label_accent_classes,
      shipping: label_default_classes,
      no_stock: 'js-stock-label ' ~ label_default_classes,
    },
    negative_discount_percentage: true,
  })
}}