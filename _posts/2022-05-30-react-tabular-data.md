---
title:       React Tabular Data
created_at:  2022-05-30 12:00:00 +00:00
layout:      default
published:   true
description:
  React tabular components are often developed in what feels like a strange inversion of the rendering flow.

keywords: java parsing data
tags: javascript react
---

When I first came to JSX in React I expected to find components that template repeating rows in a JSX table similar in format to what is finally rendered. I envisioned something like this:

```jsx
<DataGrid rows={rows}>
  <Header>
    <Th width={'30%'} sortable>Column 0</Th>
    <Th width={'30%'} sortable>Column 1</Th>
    <Th width={'20%'}>Column 2</Th>
    <Th width={'20%'}>Column 3</Th>
  </Header>
  <RowTemplate>
    <Td>{col0}</Td>
    <Td>{col1}</Td>
    <Td>{col2}</Td>
    <Td>{col3}</Td>
  </RowTemplate>
<DataGrid>
```

A lot of what you'll find with popular React [table components](https://mui.com/material-ui/react-table/) require an external definition of your columns:

```typescript
const columns: GridColDef[] = [
  { field: 'id', headerName: 'ID', width: 70 },
  { field: 'firstName', headerName: 'First name', width: 130 },
  { field: 'lastName', headerName: 'Last name', width: 130 },
  { field: 'age', headerName: 'Age', type: 'number', width: 90 },
];
```

These columns are then provided as a prop to the library component.

```jsx
// use DataGrid
<DataGrid
        rows={rows} // user data
        columns={columns}
        pageSize={5}
        rowsPerPageOptions={[5]}
        checkboxSelection
      />
```

Benefits:

1. easy to implement.
2. definable from remote payloads. 

Drawbacks:

1. contract of the columns field requires documentation (or typescript).
2. visual model of final rendering not as clear.

To figure out if the idea is even possible I decided to start small with a unordered list:

```jsx
<List rows={rows}>
  <Items/>
</List>
```

The component receives a the row data and clones the children as a template for row of data:

```jsx
function List({rows, children}) {
  return (
   <Ul>
     {rows.map((el, idx) =>
       (<Li key={idx}>{React.Children.map(children, c => React.cloneElement(c, el))}</Li>)
     )}
   </Ul>
  );
}
```

This component requires the user specify the item list and input props as a component:

```jsx
function Items({id, firstName, lastName, age}) {
  return (
    <>
      <span>{ id }</span>
      <span>{ firstName }</span>
      <span>{ lastName }</span>
      <span>{ age }</span>
    </>
  );
}
```

The implementation isn't as representational as I would hope but it is closer to my initial desire.

Benefits:

1. Closer to rendered HTML structure.
2. Greater control over items.

Drawbacks:

1. Potential for unequal header and cell count.
2. More boilerplate.

Is there a name for this pattern in the React community? Is this something library consumers would like to see more of?

Drop a comment and let me know what you think.