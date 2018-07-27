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
    expect(cartItem.count, 0);
    expect(cartItem.cost, 0);

    cartItem = CartItem(item, count: 10);
    expect(cartItem.item.name, 'ACME Widget');
    expect(cartItem.item.price, 99);
    expect(cartItem.count, 10);
    expect(cartItem.cost, 990);
  });

  test('updates count in a CartItem', () async {
    final item = Item('ACME Widget', 99);

    final cartItem = CartItem(item);
    expect(cartItem.item.name, 'ACME Widget');
    expect(cartItem.item.price, 99);
    expect(cartItem.cost, null);
    expect(cartItem.count, null);

    cartItem.count = 11;
    expect(cartItem.count, 11);
    // Need to give the stream time to propagate the change
    await Future.delayed(const Duration(microseconds: 1), () {});
    expect(cartItem.cost, 1089);
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
    final cartItem = CartItem(Item('ACME Widget', 99), count: 0);

    final tapCountKey = UniqueKey();
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
                          CartItemCountConnector(
                              (count) => Text('Count: $count')),
                          CartItemCostConnector((cost) => Text('Cost: $cost')),
                        ],
                      ),
                    )),
          ),
    ));

    // Wait for first value to flow through stream
    await tester.pump(Duration(microseconds: 1));
    expect(find.text('Count: 0'), findsOneWidget);
    expect(find.text('Cost: 0'), findsOneWidget);

    await tester.tap(find.byKey(tapCountKey));
    // Wait for new value to flow through stream
    await tester.pump(Duration(microseconds: 1));
    expect(find.text('Count: 1'), findsOneWidget);
    expect(find.text('Cost: 99'), findsOneWidget);

    await tester.tap(find.byKey(tapCountKey));
    // Wait for new value to flow through stream
    await tester.pump(Duration(microseconds: 1));
    expect(find.text('Count: 2'), findsOneWidget);
    expect(find.text('Cost: 198'), findsOneWidget);

    await tester.tap(find.byKey(tapCountKey));
    // Wait for new value to flow through stream
    await tester.pump(Duration(microseconds: 1));
    expect(find.text('Count: 3'), findsOneWidget);
    expect(find.text('Cost: 297'), findsOneWidget);
  });
}
