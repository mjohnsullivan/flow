import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow/cart.dart';

void main() {
  test('creates a new CartItem', () {
    final item = Item('ACME Widget', 99);

    var cartItem = CartItem(item);
    expect(cartItem.item.name, 'ACME Widget');
    expect(cartItem.item.price, 99);
    expect(cartItem.cost, null);
    expect(cartItem.count, null);

    cartItem = CartItem(item, count: 0);
    expect(cartItem.item.name, 'ACME Widget');
    expect(cartItem.item.price, 99);
    expect(cartItem.cost, null);
    expect(cartItem.count, 0);

    cartItem = CartItem(item, cost: 10);
    expect(cartItem.item.name, 'ACME Widget');
    expect(cartItem.item.price, 99);
    expect(cartItem.cost, 10);
    expect(cartItem.count, null);

    cartItem = CartItem(item, count: 1, cost: 10);
    expect(cartItem.item.name, 'ACME Widget');
    expect(cartItem.item.price, 99);
    expect(cartItem.cost, 10);
    expect(cartItem.count, 1);
  });

  test('updates count in a CartItem', () {
    final item = Item('ACME Widget', 99);

    final cartItem = CartItem(item);
    expect(cartItem.item.name, 'ACME Widget');
    expect(cartItem.item.price, 99);
    expect(cartItem.cost, null);
    expect(cartItem.count, null);

    cartItem.count = 11;
    expect(cartItem.count, 11);
    expect(cartItem.cost, null);
  });

  testWidgets('CartProvider is available in the widget tree', (tester) async {
    final cartItem = CartItem(Item('ACME Widget', 99));

    await tester.pumpWidget(Container(
        child: CartItemProvider(
            cartItem: cartItem,
            child: Container(child: Builder(builder: (context) {
              var cartItem = CartItemProvider.of(context);
              return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(cartItem.item.name));
            })))));

    expect(find.text('ACME Widget'), findsOneWidget);
  });

  testWidgets(
      'CartItemCountConnector and CartItemCostConnector update when the stream updates',
      (tester) async {
    final cartItem = CartItem(Item('ACME Widget', 99), count: 0, cost: 0);

    final tapCountKey = UniqueKey();
    final tapCostKey = UniqueKey();
    await tester.pumpWidget(WidgetsApp(
      color: Color(0xFF000000),
      builder: (context, _) => CartItemProvider(
            cartItem: cartItem,
            child: Builder(
                builder: (context) => Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          GestureDetector(
                            key: tapCountKey,
                            onTap: () => CartItemProvider.of(context).count++,
                            child: Text('Tap Count'),
                          ),
                          GestureDetector(
                            key: tapCostKey,
                            onTap: () => CartItemProvider.of(context).cost++,
                            child: Text('Tap Cost'),
                          ),
                          CartItemCountConnector(
                              (count) => Text('Count: $count')),
                          CartItemCostConnector((cost) => Text('Cost: $cost')),
                        ],
                      ),
                    )),
          ),
    ));

    // Wait for first value to flow through stream
    await tester.pump(Duration(milliseconds: 1));
    expect(find.text('Count: 0'), findsOneWidget);
    expect(find.text('Cost: 0'), findsOneWidget);

    await tester.tap(find.byKey(tapCountKey));
    // Wait for new value to flow through stream
    await tester.pump(Duration(milliseconds: 1));
    expect(find.text('Count: 1'), findsOneWidget);
    expect(find.text('Cost: 0'), findsOneWidget);

    await tester.tap(find.byKey(tapCountKey));
    // Wait for new value to flow through stream
    await tester.pump(Duration(milliseconds: 1));
    expect(find.text('Count: 2'), findsOneWidget);
    expect(find.text('Cost: 0'), findsOneWidget);

    await tester.tap(find.byKey(tapCostKey));
    // Wait for new value to flow through stream
    await tester.pump(Duration(milliseconds: 1));
    expect(find.text('Count: 2'), findsOneWidget);
    expect(find.text('Cost: 1'), findsOneWidget);
  });
}
